#!/bin/bash

# AvtoHelp - API Testing Script
# Tests backend API endpoints

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BASE_URL="http://localhost:3000/api"
TOKEN=""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   AvtoHelp - API Tests${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check if backend is running
echo -e "${YELLOW}Checking backend...${NC}"
if ! curl -s http://localhost:3000/health > /dev/null; then
    echo -e "${RED}❌ Backend is not running!${NC}"
    echo -e "${YELLOW}Start backend with: cd backend && npm start${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Backend is running${NC}\n"

# Test counter
PASSED=0
FAILED=0

# Helper function to test endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo -e "${YELLOW}Testing: ${description}${NC}"
    
    if [ -z "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$BASE_URL$endpoint" \
            -H "Authorization: Bearer $TOKEN" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [[ $http_code -ge 200 && $http_code -lt 300 ]]; then
        echo -e "${GREEN}✅ PASS ($http_code)${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL ($http_code)${NC}"
        echo -e "${RED}Response: $body${NC}"
        ((FAILED++))
    fi
    echo ""
}

# Test 1: Health Check
test_endpoint "GET" "/health" "" "Health Check"

# Test 2: Login
echo -e "${YELLOW}Testing: Login${NC}"
login_response=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"phone":"+998901234567","password":"password123"}')

if echo "$login_response" | grep -q "success.*true"; then
    TOKEN=$(echo "$login_response" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    echo -e "${GREEN}✅ PASS - Login successful${NC}"
    echo -e "${BLUE}Token: ${TOKEN:0:20}...${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL - Login failed${NC}"
    ((FAILED++))
fi
echo ""

# Test 3: Get Profile
test_endpoint "GET" "/auth/profile" "" "Get User Profile"

# Test 4: Get Services
test_endpoint "GET" "/services" "" "Get All Services"

# Test 5: Get Vehicles
test_endpoint "GET" "/vehicles" "" "Get User Vehicles"

# Test 6: Get Orders
test_endpoint "GET" "/orders" "" "Get User Orders"

# Test 7: Get Notifications
test_endpoint "GET" "/notifications" "" "Get Notifications"

# Test 8: Get Nearby Providers
test_endpoint "GET" "/providers/nearby?latitude=41.2995&longitude=69.2401&service_type=technical_help" "" "Get Nearby Providers"

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Test Results${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${BLUE}Total: $((PASSED + FAILED))${NC}\n"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}\n"
    exit 0
else
    echo -e "${RED}❌ Some tests failed!${NC}\n"
    exit 1
fi
