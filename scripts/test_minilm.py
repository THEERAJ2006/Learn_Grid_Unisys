import onnxruntime as ort
import numpy as np
import json

print("Testing MiniLM embedding model...")

try:
    session = ort.InferenceSession('assets/models/minilm_embeddings.onnx')
    
    # Minimal tokenised input (zeros = padding tokens)
    input_ids = np.zeros((1, 128), dtype=np.int64)
    attention_mask = np.ones((1, 128), dtype=np.int64)
    token_type_ids = np.zeros((1, 128), dtype=np.int64)
    
    outputs = session.run(None, {
        'input_ids': input_ids,
        'attention_mask': attention_mask,
        'token_type_ids': token_type_ids,
    })
    
    embedding = outputs[0][0]
    print(f"Embedding shape: {embedding.shape}")
    print(f"Embedding dim: {len(embedding)}")
    
    assert len(embedding) == 384, f"Expected 384 dims, got {len(embedding)}"
    print("MiniLM TEST: PASS ✅")
    
except FileNotFoundError:
    print("MiniLM TEST: FAIL ❌ — model file not found")
except Exception as e:
    print(f"MiniLM TEST: FAIL ❌ — {e}")
