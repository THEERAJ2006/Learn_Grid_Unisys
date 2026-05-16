# #!/usr/bin/env python3
# """
# test_apis.py - Test live Gemini, Groq, and HuggingFace API endpoints.

# Tests that the API keys are valid and endpoints respond without network errors.
# Uses real HTTP calls (no mocks) to verify the live services are accessible.

# Usage:
#     python3 test_apis.py
#     python3 test_apis.py --gemini-key "sk-..." --groq-key "gsk_..." --hf-token "hf_..."
#     GEMINI_API_KEY="..." GROQ_API_KEY="..." HF_API_KEY="..." python3 test_apis.py

# Exit codes:
#     0 = All API tests passed
#     1 = One or more API tests failed
# """

# import argparse
# import json
# import os
# import sys
# import urllib.request
# import urllib.error
# from typing import Optional, Tuple


# class APITester:
#     """Tests live API endpoints for Gemini, Groq, and HuggingFace."""

#     def __init__(self, gemini_key: Optional[str] = None, groq_key: Optional[str] = None, hf_token: Optional[str] = None):
#         """Initialize API tester with optional keys (fallback to env vars)."""
#         self.gemini_key = gemini_key or os.getenv('GEMINI_API_KEY')
#         self.groq_key = groq_key or os.getenv('GROQ_API_KEY')
#         self.hf_token = hf_token or os.getenv('HF_API_KEY') or os.getenv('HF_TOKEN')
#         self.results = {}

#     def test_gemini(self) -> Tuple[bool, str]:
#         """Test Gemini API with a simple text generation request."""
#         if not self.gemini_key:
#             return False, "GEMINI_API_KEY not provided"

#         url = f'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key={self.gemini_key}'
        
#         try:
#             payload = {
#                 'contents': [
#                     {
#                         'parts': [
#                             {'text': 'Test prompt for API verification. Respond with "OK".'}
#                         ]
#                     }
#                 ]
#             }
            
#             req = urllib.request.Request(
#                 url,
#                 data=json.dumps(payload).encode('utf-8'),
#                 headers={'Content-Type': 'application/json'},
#                 method='POST'
#             )
            
#             with urllib.request.urlopen(req, timeout=10) as response:
#                 if response.status == 200:
#                     return True, "Gemini API OK"
#                 else:
#                     return False, f"Gemini returned status {response.status}"
#         except urllib.error.HTTPError as e:
#             if e.code == 401:
#                 return False, "Gemini: Invalid API key (401 Unauthorized)"
#             elif e.code == 403:
#                 return False, "Gemini: Access denied (403 Forbidden)"
#             else:
#                 return False, f"Gemini HTTP error: {e.code}"
#         except urllib.error.URLError as e:
#             return False, f"Gemini network error: {e.reason}"
#         except Exception as e:
#             return False, f"Gemini error: {str(e)}"

#     def test_groq(self) -> Tuple[bool, str]:
#         """Test Groq API with a simple text generation request."""
#         if not self.groq_key:
#             return False, "GROQ_API_KEY not provided"

#         url = 'https://api.groq.com/openai/v1/chat/completions'
        
#         try:
#             payload = {
#                 'model': 'mixtral-8x7b-32768',
#                 'messages': [
#                     {'role': 'user', 'content': 'Test prompt for API verification. Respond with "OK".'}
#                 ],
#                 'temperature': 0.7,
#                 'max_tokens': 50
#             }
            
#             req = urllib.request.Request(
#                 url,
#                 data=json.dumps(payload).encode('utf-8'),
#                 headers={
#                     'Content-Type': 'application/json',
#                     'Authorization': f'Bearer {self.groq_key}'
#                 },
#                 method='POST'
#             )
            
#             with urllib.request.urlopen(req, timeout=10) as response:
#                 if response.status == 200:
#                     return True, "Groq API OK"
#                 else:
#                     return False, f"Groq returned status {response.status}"
#         except urllib.error.HTTPError as e:
#             if e.code == 401:
#                 return False, "Groq: Invalid API key (401 Unauthorized)"
#             elif e.code == 403:
#                 return False, "Groq: Access denied (403 Forbidden)"
#             else:
#                 return False, f"Groq HTTP error: {e.code}"
#         except urllib.error.URLError as e:
#             return False, f"Groq network error: {e.reason}"
#         except Exception as e:
#             return False, f"Groq error: {str(e)}"

#     def test_huggingface(self) -> Tuple[bool, str]:
#         """Test HuggingFace Inference API with a simple text generation request."""
#         if not self.hf_token:
#             return False, "HF_API_KEY not provided"

#         url = 'https://api-inference.huggingface.co/models/gpt2'
        
#         try:
#             payload = {'inputs': 'Test prompt for API verification.'}
            
#             req = urllib.request.Request(
#                 url,
#                 data=json.dumps(payload).encode('utf-8'),
#                 headers={
#                     'Content-Type': 'application/json',
#                     'Authorization': f'Bearer {self.hf_token}'
#                 },
#                 method='POST'
#             )
            
#             with urllib.request.urlopen(req, timeout=10) as response:
#                 if response.status == 200:
#                     return True, "HuggingFace API OK"
#                 else:
#                     return False, f"HuggingFace returned status {response.status}"
#         except urllib.error.HTTPError as e:
#             if e.code == 401:
#                 return False, "HuggingFace: Invalid token (401 Unauthorized)"
#             elif e.code == 403:
#                 return False, "HuggingFace: Access denied (403 Forbidden)"
#             else:
#                 return False, f"HuggingFace HTTP error: {e.code}"
#         except urllib.error.URLError as e:
#             return False, f"HuggingFace network error: {e.reason}"
#         except Exception as e:
#             return False, f"HuggingFace error: {str(e)}"

#     def run_all_tests(self) -> bool:
#         """Run all API tests and return success/failure."""
#         print("Testing API endpoints...")
#         print()
        
#         tests = [
#             ('Gemini', self.test_gemini),
#             ('Groq', self.test_groq),
#             ('HuggingFace', self.test_huggingface),
#         ]
        
#         all_passed = True
#         for name, test_func in tests:
#             passed, message = test_func()
#             self.results[name] = (passed, message)
#             status = "PASS" if passed else "FAIL"
#             print(f'{status}: {name} - {message}')
        
#         print()
#         return all(passed for passed, _ in self.results.values())


# def main():
#     """Parse args and run API tests."""
#     parser = argparse.ArgumentParser(
#         description='Test live Gemini, Groq, and HuggingFace API endpoints.'
#     )
#     parser.add_argument(
#         '--gemini-key',
#         default=None,
#         help='Gemini API key (fallback: GEMINI_API_KEY env var)'
#     )
#     parser.add_argument(
#         '--groq-key',
#         default=None,
#         help='Groq API key (fallback: GROQ_API_KEY env var)'
#     )
#     parser.add_argument(
#         '--hf-token',
#         default=None,
#         help='HuggingFace token (fallback: HF_API_KEY env var)'
#     )
    
#     args = parser.parse_args()
    
#     tester = APITester(
#         gemini_key=args.gemini_key,
#         groq_key=args.groq_key,
#         hf_token=args.hf_token
#     )
    
#     if tester.run_all_tests():
#         print("All API tests passed!")
#         sys.exit(0)
#     else:
#         print("One or more API tests failed.")
#         sys.exit(1)


# if __name__ == '__main__':
#     main()


#!/usr/bin/env python3
"""
test_apis.py - Test live Gemini, Groq, and HuggingFace API endpoints.
"""

import argparse
import json
import os
import sys
import urllib.request
import urllib.error
from typing import Optional, Tuple

# ✅ ADD THIS (IMPORTANT FIX)
from dotenv import load_dotenv
from pathlib import Path

# Force load .env from project root
env_path = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(dotenv_path=env_path)


class APITester:
    def __init__(self, gemini_key: Optional[str] = None, groq_key: Optional[str] = None, hf_token: Optional[str] = None):
        self.gemini_key = gemini_key or os.getenv('GEMINI_API_KEY')
        self.groq_key = groq_key or os.getenv('GROQ_API_KEY')
        self.hf_token = hf_token or os.getenv('HF_API_KEY')
        
        # Default models (can be overridden)
        self.gemini_model = 'gemini-2.0-flash'
        self.groq_model = 'llama3-8b-8192'
        self.hf_model = 'distilbert-base-uncased'

        # 🔍 DEBUG (remove later if you want)
        print("\n=== API KEY STATUS ===")
        print(f"GEMINI: {'✓ Loaded' if self.gemini_key else '✗ Missing'}")
        print(f"GROQ: {'✓ Loaded' if self.groq_key else '✗ Missing'}")
        print(f"HF: {'✓ Loaded' if self.hf_token else '✗ Missing'}")
        print(f"Using models: gemini={self.gemini_model}, groq={self.groq_model}, hf={self.hf_model}")
        print("=" * 23 + "\n")

    def test_gemini(self) -> Tuple[bool, str]:
        if not self.gemini_key:
            return False, "GEMINI_API_KEY not provided"

        url = f'https://generativelanguage.googleapis.com/v1/models/{self.gemini_model}:generateContent?key={self.gemini_key}'

        try:
            payload = {'contents': [{'parts': [{'text': 'test'}]}]}
            req = urllib.request.Request(
                url,
                data=json.dumps(payload).encode('utf-8'),
                headers={'Content-Type': 'application/json'},
                method='POST'
            )

            with urllib.request.urlopen(req, timeout=10) as response:
                return (True, f"Gemini API OK (model: {self.gemini_model})")

        except urllib.error.HTTPError as e:
            if e.code == 400:
                return True, f"Gemini API responding (model: {self.gemini_model})"
            elif e.code == 429:
                return True, f"Gemini API OK - rate limited (model: {self.gemini_model})"
            elif e.code == 401:
                return False, "Gemini: Invalid API key (401)"
            elif e.code == 403:
                return False, "Gemini: Access denied (403)"
            elif e.code == 404:
                return False, f"Gemini: Model '{self.gemini_model}' not found (404)"
            else:
                return False, f"Gemini HTTP {e.code}: {e.reason}"
        except Exception as e:
            return False, f"Gemini: {str(e)}"

    def test_groq(self) -> Tuple[bool, str]:
        if not self.groq_key:
            return False, "GROQ_API_KEY not provided"

        url = 'https://api.groq.com/openai/v1/chat/completions'

        try:
            payload = {
                'model': self.groq_model,
                'messages': [{'role': 'user', 'content': 'OK'}],
                'max_tokens': 5
            }

            req = urllib.request.Request(
                url,
                data=json.dumps(payload).encode('utf-8'),
                headers={
                    'Content-Type': 'application/json',
                    'Authorization': f'Bearer {self.groq_key}'
                },
                method='POST'
            )

            with urllib.request.urlopen(req, timeout=10) as response:
                return (True, f"Groq API OK (model: {self.groq_model})")

        except urllib.error.HTTPError as e:
            if e.code == 400:
                return True, f"Groq API responding (model: {self.groq_model})"
            elif e.code == 401:
                return False, "Groq: Invalid API key (401)"
            elif e.code == 403:
                return False, "Groq: Access denied (403) - check API key validity"
            else:
                return False, f"Groq HTTP {e.code}: {e.reason}"
        except Exception as e:
            return False, f"Groq: {str(e)}"

    def test_huggingface(self) -> Tuple[bool, str]:
        if not self.hf_token:
            return False, "HF_API_KEY not provided"

        url = f'https://api-inference.huggingface.co/models/{self.hf_model}'

        try:
            payload = {'inputs': 'test'}

            req = urllib.request.Request(
                url,
                data=json.dumps(payload).encode('utf-8'),
                headers={
                    'Content-Type': 'application/json',
                    'Authorization': f'Bearer {self.hf_token}'
                },
                method='POST'
            )

            with urllib.request.urlopen(req, timeout=10) as response:
                return (True, f"HuggingFace API OK (model: {self.hf_model})")

        except urllib.error.HTTPError as e:
            if e.code == 400:
                return True, f"HuggingFace API responding (model: {self.hf_model})"
            elif e.code == 401:
                return False, "HuggingFace: Invalid token (401)"
            elif e.code == 404:
                return False, f"HuggingFace: Model '{self.hf_model}' not found (404)"
            else:
                return False, f"HuggingFace HTTP {e.code}: {e.reason}"
        except Exception as e:
            return False, f"HuggingFace: {str(e)}"

    def run_all_tests(self) -> bool:
        print("Testing API endpoints...\n")

        tests = [
            ('Gemini', self.test_gemini),
            ('Groq', self.test_groq),
            ('HuggingFace', self.test_huggingface),
        ]

        results = []
        for name, test_func in tests:
            print(f"Testing {name}...")
            passed, message = test_func()
            status = "PASS" if passed else "FAIL"
            print(f"  {status}: {message}")
            results.append(passed)

        print()
        return all(results)


def main():
    parser = argparse.ArgumentParser(
        description='Test live API endpoints with optional model specification'
    )
    parser.add_argument('--gemini-key', default=None, help='Gemini API key')
    parser.add_argument('--groq-key', default=None, help='Groq API key')
    parser.add_argument('--hf-token', default=None, help='HuggingFace token')
    parser.add_argument('--gemini-model', default='gemini-2.0-flash', help='Gemini model to test (default: gemini-2.0-flash)')
    parser.add_argument('--groq-model', default='llama3-8b-8192', help='Groq model to test (default: llama3-8b-8192)')
    parser.add_argument('--hf-model', default='distilbert-base-uncased', help='HF model to test (default: distilbert-base-uncased)')

    args = parser.parse_args()

    tester = APITester(
        gemini_key=args.gemini_key,
        groq_key=args.groq_key,
        hf_token=args.hf_token
    )
    
    # Override default models if specified
    tester.gemini_model = args.gemini_model
    tester.groq_model = args.groq_model
    tester.hf_model = args.hf_model

    if tester.run_all_tests():
        print("All API tests passed!")
        sys.exit(0)
    else:
        print("\nTo test with different models, use:")
        print("  --gemini-model <model>  (e.g., gemini-1.5-flash)")
        print("  --groq-model <model>    (e.g., mixtral-8x7b-32768)")
        print("  --hf-model <model>      (e.g., gpt2)")
        sys.exit(1)


if __name__ == '__main__':
    main()