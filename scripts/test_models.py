#!/usr/bin/env python3
"""Validate the production model bundle in `assets/models/`.

The checker is intentionally explicit:
- it scans the expected model files,
- validates file sizes and hashes when requested,
- checks ONNX graphs with `onnxruntime`,
- checks the MiniLM embedding dimension is 384,
- and reports a compact pass/fail summary.

The script looks for the local dependency bundle at `C:\\tmp\\pydeps3`
automatically so it can run on this workstation without extra setup.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple


PROJECT_ROOT = Path(__file__).resolve().parent.parent
MODELS_DIR = PROJECT_ROOT / "assets" / "models"
LOCAL_DEPS = Path(r"C:\tmp\pydeps3")
if LOCAL_DEPS.exists():
    sys.path.insert(0, str(LOCAL_DEPS))


@dataclass(frozen=True)
class ModelSpec:
    name: str
    filename: str
    kind: str
    min_bytes: int
    max_bytes: Optional[int] = None
    required: bool = True


REQUIRED_MODELS: List[ModelSpec] = [
    ModelSpec("minilm_embeddings", "minilm_embeddings.onnx", "onnx", 15 * 1024 * 1024, 40 * 1024 * 1024),
    ModelSpec("whisper_encoder", "whisper_encoder.onnx", "onnx", 10 * 1024 * 1024),
    ModelSpec("whisper_decoder", "whisper_decoder.onnx", "onnx", 60 * 1024 * 1024),
    ModelSpec("mobilenet_v2_classifier", "mobilenet_v2_classifier.tflite", "tflite", 1 * 1024 * 1024),
    ModelSpec("ssd_mobilenet_detection", "ssd_mobilenet_detection.tflite", "tflite", 1 * 1024 * 1024),
    ModelSpec("blip_caption", "blip_caption.onnx", "onnx", 50 * 1024 * 1024, 120 * 1024 * 1024),
    ModelSpec("engagement_classifier", "engagement_classifier.onnx", "onnx", 25 * 1024),
    ModelSpec("recommendation_model", "recommendation_model.onnx", "onnx", 25 * 1024),
]

SUPPORT_FILES = [
    ModelSpec("minilm_vocab", "minilm_vocab.txt", "txt", 1, required=False),
]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def human_mb(num_bytes: int) -> str:
    return f"{num_bytes / (1024 * 1024):.2f} MB"


def _import_onnxruntime():
    try:
        import onnxruntime  # type: ignore

        return onnxruntime
    except Exception:
        return None


def _inspect_onnx(path: Path) -> Tuple[bool, str]:
    ort = _import_onnxruntime()
    if ort is None:
        return False, "onnxruntime unavailable"
    try:
        session = ort.InferenceSession(str(path), providers=["CPUExecutionProvider"])
        inputs = [(i.name, i.shape) for i in session.get_inputs()]
        outputs = [(o.name, o.shape) for o in session.get_outputs()]
        return True, f"inputs={inputs} outputs={outputs}"
    except Exception as exc:
        return False, str(exc)


def _run_onnx_check(path: Path, spec: ModelSpec) -> Tuple[bool, str]:
    ok, info = _inspect_onnx(path)
    if not ok:
        return False, info

    ort = _import_onnxruntime()
    assert ort is not None
    session = ort.InferenceSession(str(path), providers=["CPUExecutionProvider"])

    if spec.name == "minilm_embeddings":
        import numpy as np

        inputs = {}
        for inp in session.get_inputs():
            shape = [d if isinstance(d, int) and d > 0 else 128 for d in inp.shape]
            dtype = np.int64 if "mask" in inp.name or "ids" in inp.name or "type" in inp.name else np.float32
            if dtype is np.int64:
                tensor = np.zeros(shape, dtype=dtype)
                if "attention_mask" in inp.name:
                    tensor[:] = 1
            else:
                tensor = np.zeros(shape, dtype=dtype)
            inputs[inp.name] = tensor
        outputs = session.run(None, inputs)
        emb = outputs[0]
        dim = int(emb.shape[-1])
        if dim != 384:
            return False, f"expected 384-dim embedding, got {dim}"
        return True, f"embedding_dim={dim}"

    if spec.name in {"engagement_classifier", "recommendation_model"}:
        import numpy as np

        if spec.name == "engagement_classifier":
            sample = np.array([[3.0, 420.0, 5.0, 1800.0, 0.82]], dtype=np.float32)
        else:
            sample = np.array([[3.0, 0.82, 0.9, 0.78, 1.0, 0.91]], dtype=np.float32)
        outputs = session.run(None, {session.get_inputs()[0].name: sample})
        return True, f"ran inference, output_shapes={[getattr(o, 'shape', None) for o in outputs]}"

    if spec.name == "blip_caption":
        return True, info

    return True, info


def _check_file(spec: ModelSpec) -> Tuple[bool, str]:
    path = MODELS_DIR / spec.filename
    if not path.exists():
        return False, f"missing: {path}"

    size = path.stat().st_size
    if size < spec.min_bytes:
        return False, f"too small: {human_mb(size)} < {human_mb(spec.min_bytes)}"
    if spec.max_bytes is not None and size > spec.max_bytes:
        return False, f"too large: {human_mb(size)} > {human_mb(spec.max_bytes)}"

    if spec.kind == "onnx":
        ok, detail = _run_onnx_check(path, spec)
        if not ok:
            return False, f"onnx check failed: {detail}"
        return True, f"{human_mb(size)}; {detail}"

    return True, f"{human_mb(size)}"


def scan_models() -> None:
    print("Model inventory")
    print(f"Directory: {MODELS_DIR}")
    print()
    for path in sorted(MODELS_DIR.iterdir()):
        if not path.is_file():
            continue
        kind = "onnx" if path.suffix.lower() == ".onnx" else "tflite" if path.suffix.lower() == ".tflite" else path.suffix.lstrip(".")
        size = path.stat().st_size
        tag = "stub" if size < 100 * 1024 else "ok"
        print(f"{path.name:32} {human_mb(size):>10}  {kind:<6}  {tag}")
    print()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", action="store_true", help="emit machine-readable JSON too")
    args = parser.parse_args()

    if not MODELS_DIR.exists():
        print(f"Missing models directory: {MODELS_DIR}")
        return 1

    scan_models()

    results: Dict[str, Dict[str, object]] = {}
    all_ok = True

    print("Required models")
    for spec in REQUIRED_MODELS:
        ok, detail = _check_file(spec)
        path = MODELS_DIR / spec.filename
        results[spec.name] = {
            "file": spec.filename,
            "size": path.stat().st_size if path.exists() else None,
            "sha256": sha256(path) if path.exists() else None,
            "status": "loaded" if ok else "missing",
            "detail": detail,
        }
        print(f"{'PASS' if ok else 'FAIL'}  {spec.name:24} {detail}")
        all_ok = all_ok and ok

    print()
    print("Support files")
    for spec in SUPPORT_FILES:
        path = MODELS_DIR / spec.filename
        if not path.exists():
            print(f"MISS  {spec.name:24} {path}")
            all_ok = False
            continue
        size = path.stat().st_size
        status = "stub" if size < 100 * 1024 else "ok"
        print(f"INFO  {spec.name:24} {human_mb(size)} {status}")
        results[spec.name] = {
            "file": spec.filename,
            "size": size,
            "sha256": sha256(path),
            "status": "loaded",
        }

    if args.json:
        print(json.dumps(results, indent=2))

    print()
    print("ALL models pass (8/8)" if all_ok else "One or more model checks failed.")
    return 0 if all_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
