#!/usr/bin/env python3
"""
LearnGrid Datasets Download Script
Downloads training and reference datasets for ML model training.
NOTE:
  - Some datasets are very large and/or gated behind account/terms (Kaggle, OULAD, Common Voice).
  - This script downloads what it can automatically (public sources), skips existing downloads,
    and writes a manifest + exact manual commands for gated sources.
  - It never creates synthetic data or fake placeholders.
"""

import os
import sys
import json
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import hashlib
import subprocess
import time

PROJECT_ROOT = Path(__file__).parent.parent
DATA_DIR = PROJECT_ROOT / "scripts" / "data"
DATA_DIR.mkdir(parents=True, exist_ok=True)

DATASET_MANIFEST = {
    "datasets": {},
    "instructions": {},
    "metadata": {},
}

def _pip_install(packages: List[str]) -> None:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "--upgrade", *packages])

def _ensure_core_deps() -> None:
    try:
        import requests  # noqa: F401
        from tqdm import tqdm  # noqa: F401
    except ImportError:
        print("Installing required packages (requests, tqdm)...")
        _pip_install(["requests", "tqdm"])

_ensure_core_deps()
import requests  # noqa: E402
from tqdm import tqdm  # noqa: E402

def _rel(p: Path) -> str:
    try:
        return str(p.relative_to(PROJECT_ROOT)).replace("\\", "/")
    except Exception:
        return str(p).replace("\\", "/")

def _sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def _record_dataset(
    key: str,
    *,
    description: str,
    source_url: str,
    license: str,
    local_path: Path,
    status: str,
    extra: Optional[Dict] = None,
) -> None:
    entry: Dict = {
        "description": description,
        "source_url": source_url,
        "license": license,
        "local_path": _rel(local_path),
        "status": status,
    }
    if local_path.exists():
        if local_path.is_file():
            entry["bytes"] = local_path.stat().st_size
            entry["sha256"] = _sha256(local_path)
        else:
            total = 0
            files = 0
            for p in local_path.rglob("*"):
                if p.is_file():
                    files += 1
                    total += p.stat().st_size
            entry["bytes"] = total
            entry["file_count"] = files
    if extra:
        entry.update(extra)
    DATASET_MANIFEST["datasets"][key] = entry

def _git_clone(url: str, dest: Path) -> Tuple[bool, str]:
    if dest.exists():
        return True, "already present"
    dest.parent.mkdir(parents=True, exist_ok=True)
    try:
        subprocess.check_call(["git", "clone", url, str(dest)])
        return True, "cloned"
    except Exception as e:
        return False, str(e)

DATASETS = {
    "ck12_textbooks": {
        "description": "CK-12 Foundation Open Educational Textbooks",
        "url": "https://www.ck12.org/fbbrowse/",
        "size_gb": 2,
        "format": "PDF + JSON",
        "license": "CC BY",
        "instructions": "Download via CK-12 website or use their API",
        "local_path": "scripts/data/textbooks/ck12"
    },
    "siyavula_textbooks": {
        "description": "SIYAVULA Open Textbooks (Science, Maths, English)",
        "url": "https://www.siyavula.com/read",
        "size_gb": 1,
        "format": "HTML + PDF",
        "license": "CC BY",
        "instructions": "Download textbook PDFs from website",
        "local_path": "scripts/data/textbooks/siyavula"
    },
    "student_engagement_dataset": {
        "description": "Student Engagement Dataset (Kaggle)",
        "url": "https://www.kaggle.com/datasets/iashiqul/student-engagement-dataset",
        "size_gb": 0.1,
        "format": "CSV",
        "license": "CC0",
        "instructions": "kaggle datasets download iashiqul/student-engagement-dataset",
        "local_path": "scripts/data/engagement"
    },
    "daisee_dataset": {
        "description": "DAiSEE Dataset (Engagement Detection)",
        "url": "https://iith.ac.in/~daisee-dataset/",
        "size_gb": 10,
        "format": "Video + Annotations",
        "license": "Academic",
        "instructions": "Request access from IITH, download .zip files",
        "local_path": "scripts/data/engagement/daisee"
    },
    "oulad": {
        "description": "Open University Learning Analytics Dataset",
        "url": "https://analyse.kmi.open.ac.uk/open_dataset",
        "size_gb": 0.5,
        "format": "CSV",
        "license": "CC BY",
        "instructions": "Download studentInfo.csv, studentAssessment.csv, courses.csv",
        "local_path": "scripts/data/recommendation"
    },
    "figureqa": {
        "description": "FigureQA - Scientific Figure Understanding",
        "url": "https://github.com/Maluuba/FigureQA",
        "size_gb": 2,
        "format": "PNG + JSON",
        "license": "Apache 2.0",
        "instructions": "git clone https://github.com/Maluuba/FigureQA.git",
        "local_path": "scripts/data/image_classification/figureqa"
    },
    "imageclef_medical": {
        "description": "CLEF ImageCLEF Medical Dataset (2019)",
        "url": "https://www.imageclef.org/2019/medical",
        "size_gb": 3,
        "format": "JPG + XML",
        "license": "Academic",
        "instructions": "Register and download from ImageCLEF website",
        "local_path": "scripts/data/image_classification/medical"
    },
    "mozilla_common_voice": {
        "description": "Mozilla Common Voice (Multilingual Speech Data)",
        "url": "https://commonvoice.mozilla.org/en/datasets",
        "size_gb": 5,  # Varies by language
        "format": "MP3 + CSV",
        "license": "CC0",
        "instructions": "Download for languages: English, Hindi, Tamil, Swahili",
        "local_path": "scripts/data/speech/common_voice",
        "languages": ["en", "hi", "ta", "sw"]
    },
    "khan_academy_kolibri": {
        "description": "Khan Academy Content via Kolibri (Educational Videos)",
        "url": "https://kolibri.readthedocs.io/en/latest/install.html",
        "size_gb": 10,  # Varies by selection
        "format": "MP4 + SRT",
        "license": "CC BY-NC",
        "instructions": "Use Kolibri offline package importer",
        "local_path": "assets/content/videos"
    },
    "mit_ocw_videos": {
        "description": "MIT OpenCourseWare Videos",
        "url": "https://ocw.mit.edu/",
        "size_gb": 5,  # Varies
        "format": "MP4",
        "license": "CC BY-NC-SA",
        "instructions": "Download individual course videos via ocw.mit.edu",
        "local_path": "assets/content/videos/mit_ocw"
    }
}

def _download_public_sources() -> bool:
    """
    Downloads what is publicly accessible without credentials.
    """
    ok = True

    # D. Image Classification / Diagram Dataset — FigureQA (public repo)
    figureqa_dir = DATA_DIR / "image_classification" / "figureqa"
    print("\n[1/2] FigureQA (public) — cloning repo...")
    success, msg = _git_clone("https://github.com/Maluuba/FigureQA.git", figureqa_dir)
    _record_dataset(
        "figureqa",
        description="FigureQA repo clone (dataset download steps live in repo README)",
        source_url="https://github.com/Maluuba/FigureQA",
        license="Apache-2.0",
        local_path=figureqa_dir,
        status=("downloaded" if success else "failed"),
        extra={"detail": msg},
    )
    ok = ok and success

    return ok

def _record_manual_sources() -> None:
    """
    Records manual steps for gated/large sources (so we never claim they are downloaded).
    """
    # A. CK-12 + Siyavula textbooks
    textbooks_dir = PROJECT_ROOT / "assets" / "content" / "textbooks"
    textbooks_dir.mkdir(parents=True, exist_ok=True)
    _record_dataset(
        "textbooks_ck12_siyavula",
        description="CK-12 + Siyavula open textbooks (download at least 10 chapters PDFs + extracted text JSON)",
        source_url="https://www.ck12.org/fbbrowse/ and https://www.siyavula.com/read",
        license="CC BY (verify per book)",
        local_path=textbooks_dir,
        status="manual download required (site/API-specific)",
        extra={"target": "assets/content/textbooks/"},
    )

    # B. Kaggle engagement dataset (auth-gated)
    engagement_dir = DATA_DIR / "engagement"
    engagement_dir.mkdir(parents=True, exist_ok=True)
    _record_dataset(
        "student_engagement_kaggle",
        description="Student Engagement Dataset (tabular) for engagement model training",
        source_url="https://www.kaggle.com/datasets/iashiqul/student-engagement-dataset",
        license="See Kaggle listing",
        local_path=engagement_dir,
        status="manual download required (kaggle auth)",
        extra={
            "command": "kaggle datasets download iashiqul/student-engagement-dataset -p scripts/data/engagement --unzip",
            "requires": "~/.kaggle/kaggle.json",
        },
    )

    # C. OULAD (terms gate)
    rec_dir = DATA_DIR / "recommendation"
    rec_dir.mkdir(parents=True, exist_ok=True)
    _record_dataset(
        "oulad_recommendation",
        description="OULAD CSVs for recommendation model training (studentInfo.csv, studentAssessment.csv, courses.csv)",
        source_url="https://analyse.kmi.open.ac.uk/open_dataset",
        license="CC BY (verify terms)",
        local_path=rec_dir,
        status="manual download required (terms gate)",
        extra={"required_files": ["studentInfo.csv", "studentAssessment.csv", "courses.csv"]},
    )

    # E. Common Voice (large, per-language bundles)
    speech_dir = DATA_DIR / "speech" / "common_voice"
    speech_dir.mkdir(parents=True, exist_ok=True)
    _record_dataset(
        "mozilla_common_voice",
        description="Mozilla Common Voice validated.tsv + clips for English, Hindi, Tamil, Swahili",
        source_url="https://commonvoice.mozilla.org/en/datasets",
        license="CC0",
        local_path=speech_dir,
        status="manual download required (large bundles)",
        extra={"languages": ["en", "hi", "ta", "sw"]},
    )

    # F. Sample educational videos
    videos_dir = PROJECT_ROOT / "assets" / "content" / "videos"
    videos_dir.mkdir(parents=True, exist_ok=True)
    _record_dataset(
        "sample_videos",
        description="Sample educational videos for testing video pipeline (>=3 per subject)",
        source_url="https://ocw.mit.edu/ and https://kolibri.readthedocs.io/en/latest/install.html",
        license="CC (varies, verify per source)",
        local_path=videos_dir,
        status="manual download required",
    )

def create_dataset_manifest():
    """Create a reference manifest for all datasets."""
    print("\n[2/2] Writing dataset manifest...")
    
    total_size = sum(d.get("size_gb", 0) for d in DATASETS.values())
    
    # Keep the original dataset catalogue for reference, but also keep the
    # per-dataset status entries we recorded in DATASET_MANIFEST["datasets"].
    DATASET_MANIFEST["catalogue"] = DATASETS
    DATASET_MANIFEST["instructions"] = {
        "total_size_gb": total_size,
        "note": "Some datasets require manual downloads due to licensing/terms/auth. See per-dataset status entries.",
        "quick_start": [
            "1. Textbooks (for content): Download CK-12 + SIYAVULA (~3 GB)",
            "2. Engagement data: Kaggle dataset (~0.1 GB)",
            "3. Recommendation: OULAD (~0.5 GB)",
            "4. Video samples: 3-5 sample videos (~500 MB)"
        ],
        "full_ml_training": [
            "For comprehensive ML model training:",
            "1. Student Engagement (~20 GB with DAiSEE)",
            "2. Learning Analytics (OULAD)",
            "3. Speech Data (Mozilla Common Voice ~20 GB)",
            "4. Image Datasets (FigureQA + Medical)"
        ]
    }
    
    manifest_path = PROJECT_ROOT / "scripts" / "data" / "dataset_manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(manifest_path, 'w', encoding="utf-8") as f:
        json.dump(DATASET_MANIFEST, f, indent=2)
    
    print(f"  [OK] Manifest created: {_rel(manifest_path)}")

def print_dataset_guide():
    """Print dataset download guide."""
    print("\n" + "="*70)
    print("LearnGrid DATASETS REFERENCE GUIDE")
    print("="*70)
    
    print("\nDATASET OVERVIEW:")
    print("-" * 70)
    
    for name, info in DATASETS.items():
        print(f"\n{name.upper()}")
        print(f"  Description: {info['description']}")
        print(f"  URL: {info['url']}")
        print(f"  Size: ~{info['size_gb']} GB")
        print(f"  Format: {info['format']}")
        print(f"  License: {info['license']}")
        print(f"  Local Path: {info['local_path']}")
        print(f"  Instructions: {info['instructions']}")
        if 'languages' in info:
            print(f"  Languages: {', '.join(info['languages'])}")
    
    total_size = sum(d.get("size_gb", 0) for d in DATASETS.values())
    print(f"\nTOTAL SIZE (if downloading all): ~{total_size} GB")
    
    print("\nQUICK START (MVP - ~3 GB):")
    print("  1. CK-12 Textbooks")
    print("  2. Student Engagement Dataset (Kaggle)")
    print("  3. 5 sample videos from Khan Academy or MIT OCW")
    
    print("\nFOR FULL ML TRAINING (~50+ GB):")
    print("  1. All textbooks")
    print("  2. DAiSEE dataset (for engagement classifier)")
    print("  3. OULAD (for recommendation model)")
    print("  4. Mozilla Common Voice (for speech recognition)")
    print("  5. All image datasets")
    
    print("\n" + "="*70 + "\n")

def main():
    """Main routine."""
    print("\n" + "="*70)
    print("LearnGrid Datasets Download")
    print("="*70)
    
    try:
        DATASET_MANIFEST["metadata"] = {
            "created_at": time.strftime("%Y-%m-%dT%H:%M:%S"),
            "generated_by": "scripts/download_datasets.py",
        }

        ok_public = _download_public_sources()
        _record_manual_sources()

        print_dataset_guide()
        create_dataset_manifest()
        
        print("[OK] Dataset manifest created.")
        print("[OK] See scripts/data/dataset_manifest.json for details (downloaded vs manual).")
        
        # Non-zero only if a public automated download failed.
        return 0 if ok_public else 1
    
    except Exception as e:
        print(f"\n[ERROR] {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    sys.exit(main())
