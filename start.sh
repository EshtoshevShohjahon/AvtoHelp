#!/bin/bash

# AvtoHelp - Quick Start Script
# Starts backend and mobile app simultaneously

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   AvtoHelp - Quick Start${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check if setup was run
if [ ! -f backend/.env ]; then
    echo -e "${RED}❌ Backend not configured!${NC}"
    echo -e "${YELLOW}Please run: ./setup.sh${NC}"
    exit 1
fi

if [ ! -d backend/node_modules ]; then
    echo -e "${RED}❌ Backend dependencies not installed!${NC}"
    echo -e "${YELLOW}Please run: ./setup.sh${NC}"
    exit 1
fi

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}Stopping services...${NC}"
    kill $(jobs -p) 2>/dev/null || true
    echo -e "${GREEN}✅ Services stopped${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start backend
echo -e "${YELLOW}[1/2] Starting Backend Server...${NC}"
cd backend
npm start &
BACKEND_PID=$!
echo -e "${GREEN}✅ Backend started (PID: $BACKEND_PID)${NC}"
echo -e "${BLUE}Backend running at: http://localhost:3000${NC}\n"
cd ..

# Wait for backend to be ready
echo -e "${YELLOW}Waiting for backend to be ready...${NC}"
sleep 3

# Check if backend is running
if ! curl -s http://localhost:3000/health > /dev/null; then
    echo -e "${RED}❌ Backend failed to start!${NC}"
    kill $BACKEND_PID 2>/dev/null || true
    exit 1
fi
echo -e "${GREEN}✅ Backend is ready${NC}\n"

# Start mobile (Flutter)
echo -e "${YELLOW}[2/2] Starting Flutter Mobile App...${NC}"
cd mobile

# Check for connected devices
DEVICES=$(flutter devices | grep -c "device" || true)
if [ $DEVICES -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No devices found!${NC}"
    echo -e "${YELLOW}Please start an emulator or connect a device, then run:${NC}"
    echo -e "${GREEN}cd mobile && flutter run${NC}\n"
    echo -e "${BLUE}Backend is still running at: http://localhost:3000${NC}"
    wait $BACKEND_PID
else
    echo -e "${GREEN}✅ Device(s) found${NC}"
    flutter run &
    FLUTTER_PID=$!
    echo -e "${GREEN}✅ Flutter app started (PID: $FLUTTER_PID)${NC}\n"
fi

cd ..

# Display info
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   AvtoHelp is running!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}Services:${NC}"
echo -e "  Backend API: ${GREEN}http://localhost:3000${NC}"
echo -e "  Health Check: ${GREEN}http://localhost:3000/health${NC}\n"

echo -e "${BLUE}Demo login:${NC}"
echo -e "  Phone: ${GREEN}+998901234567${NC}"
echo -e "  Password: ${GREEN}password123${NC}\n"

echo -e "${YELLOW}Press Ctrl+C to stop all services${NC}\n"

# Keep script running
wait
