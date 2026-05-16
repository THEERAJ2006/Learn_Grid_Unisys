#!/bin/bash
# run_all_tests.sh - Master test orchestrator for LearnGrid
#
# Runs all tests in sequence:
#   1. flutter analyze - Static analysis
#   2. flutter test    - Dart unit tests (5 test files)
#   3. Flutter builds  - Verify build succeeds
#   4. Python API tests
#   5. Model verification
#   6. Database schema verification
#
# Exit code: 0 = all tests passed, 1 = any test failed
#
# Usage:
#   bash scripts/run_all_tests.sh
#   bash scripts/run_all_tests.sh --no-python  # Skip Python tests
#   bash scripts/run_all_tests.sh --no-build   # Skip Flutter builds

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( dirname "$SCRIPT_DIR" )"
SKIP_PYTHON=false
SKIP_BUILD=false
SKIP_ANALYZE=false

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --no-python) SKIP_PYTHON=true ;;
        --no-build) SKIP_BUILD=true ;;
        --no-analyze) SKIP_ANALYZE=true ;;
        --help)
            echo "Usage: bash run_all_tests.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-python    Skip Python tests"
            echo "  --no-build     Skip Flutter builds"
            echo "  --no-analyze   Skip flutter analyze"
            echo "  --help         Show this help message"
            exit 0
            ;;
    esac
done

# Initialize counters
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=""

# Utility functions
log_test_start() {
    echo -e "\n${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}\n"
}

log_test_pass() {
    echo -e "${GREEN}✓ $1${NC}"
    ((TESTS_PASSED++))
}

log_test_fail() {
    echo -e "${RED}✗ $1${NC}"
    ((TESTS_FAILED++))
    FAILED_TESTS="$FAILED_TESTS\n  - $1"
}

cd "$PROJECT_ROOT"

# ============================================================================
# TEST 1: Flutter Analyze (Static Analysis)
# ============================================================================

if [ "$SKIP_ANALYZE" = false ]; then
    log_test_start "TEST 1: Flutter Analyze"
    
    if command -v flutter &> /dev/null; then
        if flutter analyze --no-fatal-infos; then
            log_test_pass "flutter analyze"
        else
            log_test_fail "flutter analyze - Static analysis issues found"
        fi
    else
        echo "⚠ flutter not found in PATH - skipping flutter analyze"
    fi
fi

# ============================================================================
# TEST 2: Flutter Test (Dart Unit Tests)
# ============================================================================

log_test_start "TEST 2: Flutter Unit Tests"

if command -v flutter &> /dev/null; then
    if flutter test --reporter expanded 2>&1; then
        log_test_pass "flutter test (all 5 test files)"
    else
        log_test_fail "flutter test - One or more tests failed"
    fi
else
    echo "⚠ flutter not found in PATH - skipping flutter test"
    echo "  Ensure Flutter is installed and in PATH"
fi

# ============================================================================
# TEST 3: Flutter Build (Android, iOS, Web)
# ============================================================================

if [ "$SKIP_BUILD" = false ]; then
    log_test_start "TEST 3: Flutter Build Verification"
    
    if command -v flutter &> /dev/null; then
        # Try building for web (most reliable for testing)
        if flutter build web --release 2>&1 | tail -20; then
            log_test_pass "flutter build web"
        else
            log_test_fail "flutter build web - Build failed"
        fi
    else
        echo "⚠ flutter not found in PATH - skipping builds"
    fi
fi

# ============================================================================
# TEST 4: Python API Tests
# ============================================================================

if [ "$SKIP_PYTHON" = false ]; then
    log_test_start "TEST 4: Python API Tests"
    
    if command -v python3 &> /dev/null; then
        if python3 "$SCRIPT_DIR/test_apis.py"; then
            log_test_pass "test_apis.py (Gemini/Groq/HF endpoints)"
        else
            log_test_fail "test_apis.py - API tests failed"
        fi
    else
        echo "⚠ python3 not found - skipping Python API tests"
    fi
fi

# ============================================================================
# TEST 5: Model Verification
# ============================================================================

if [ "$SKIP_PYTHON" = false ]; then
    log_test_start "TEST 5: Model Verification"
    
    if command -v python3 &> /dev/null; then
        if python3 "$SCRIPT_DIR/test_models.py"; then
            log_test_pass "test_models.py (8 model files)"
        else
            log_test_fail "test_models.py - Model verification failed"
        fi
    else
        echo "⚠ python3 not found - skipping model verification"
    fi
fi

# ============================================================================
# TEST 6: Database Schema Verification
# ============================================================================

if [ "$SKIP_PYTHON" = false ]; then
    log_test_start "TEST 6: Database Schema Verification"
    
    if command -v python3 &> /dev/null; then
        # Check if database exists
        if [ -f "build/web/learngrid.db" ]; then
            if python3 "$SCRIPT_DIR/test_db.py" --db-path "build/web/learngrid.db"; then
                log_test_pass "test_db.py (schema + 11 indexes)"
            else
                log_test_fail "test_db.py - Database schema verification failed"
            fi
        else
            echo "⚠ learngrid.db not found in build/web"
            echo "  Run 'flutter build web' first, or manually copy database"
        fi
    else
        echo "⚠ python3 not found - skipping database verification"
    fi
fi

# ============================================================================
# FINAL SUMMARY
# ============================================================================

echo -e "\n${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}TEST SUMMARY${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}\n"

echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"

if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "\n${RED}Failed Tests:${NC}"
    echo -e "$FAILED_TESTS"
fi

echo ""

if [ $TESTS_FAILED -eq 0 ] && [ $TESTS_PASSED -gt 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}\n"
    exit 0
else
    echo -e "${RED}✗ One or more tests failed${NC}\n"
    exit 1
fi
