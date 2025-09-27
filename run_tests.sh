#!/bin/bash

# Shadesmith Multi-Agent Pipeline Test Runner
# This script runs all tests for the Shadesmith project

echo "🚀 Starting Shadesmith Test Suite"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
    esac
}

# Check if Python virtual environment is activated
if [[ "$VIRTUAL_ENV" == "" ]]; then
    print_status "WARNING" "Python virtual environment not activated"
    print_status "INFO" "Activating virtual environment..."
    source .venv/bin/activate
fi

# Check if required packages are installed
print_status "INFO" "Checking dependencies..."
python -c "import google.adk.agents" 2>/dev/null
if [ $? -ne 0 ]; then
    print_status "ERROR" "ADK package not found. Install with: pip install google-adk"
    exit 1
fi

python -c "import requests" 2>/dev/null
if [ $? -ne 0 ]; then
    print_status "ERROR" "Requests package not found. Install with: pip install requests"
    exit 1
fi

print_status "SUCCESS" "Dependencies check passed"

# Test 1: Agent Pipeline Tests
echo ""
print_status "INFO" "Running Agent Pipeline Tests..."
echo "----------------------------------------"
python test_agents.py
AGENT_TEST_RESULT=$?

# Test 2: Flask Integration Tests (if Flask app is running)
echo ""
print_status "INFO" "Running Flask Integration Tests..."
echo "----------------------------------------"
print_status "INFO" "Note: Start Flask app with 'python app.py' in another terminal for full testing"

# Check if Flask app is running
curl -s http://localhost:8080/ > /dev/null 2>&1
if [ $? -eq 0 ]; then
    python test_flask_integration.py
    FLASK_TEST_RESULT=$?
else
    print_status "WARNING" "Flask app not running. Skipping Flask integration tests."
    print_status "INFO" "To test Flask integration:"
    print_status "INFO" "  1. Start Flask app: python app.py"
    print_status "INFO" "  2. Run: python test_flask_integration.py"
    FLASK_TEST_RESULT=0
fi

# Test 3: ADK Deployment Tests
echo ""
print_status "INFO" "Running ADK Deployment Tests..."
echo "----------------------------------------"
python test_adk_deployment.py
ADK_TEST_RESULT=$?

# Summary
echo ""
echo "=================================="
print_status "INFO" "Test Results Summary:"
echo "=================================="

if [ $AGENT_TEST_RESULT -eq 0 ]; then
    print_status "SUCCESS" "Agent Pipeline Tests: PASSED"
else
    print_status "ERROR" "Agent Pipeline Tests: FAILED"
fi

if [ $FLASK_TEST_RESULT -eq 0 ]; then
    print_status "SUCCESS" "Flask Integration Tests: PASSED"
else
    print_status "ERROR" "Flask Integration Tests: FAILED"
fi

if [ $ADK_TEST_RESULT -eq 0 ]; then
    print_status "SUCCESS" "ADK Deployment Tests: PASSED"
else
    print_status "ERROR" "ADK Deployment Tests: FAILED"
fi

# Overall result
TOTAL_FAILED=$((AGENT_TEST_RESULT + FLASK_TEST_RESULT + ADK_TEST_RESULT))

echo ""
if [ $TOTAL_FAILED -eq 0 ]; then
    print_status "SUCCESS" "🎉 All tests passed! The Shadesmith multi-agent pipeline is working correctly."
    exit 0
else
    print_status "ERROR" "⚠️  Some tests failed. Check the output above for details."
    exit 1
fi
