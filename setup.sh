#!/bin/bash

# AvtoHelp - Automated Setup Script
# This script sets up the entire AvtoHelp application (backend + mobile)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   AvtoHelp - Automated Setup${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check if PostgreSQL is installed
echo -e "${YELLOW}[1/6] Checking PostgreSQL...${NC}"
if ! command -v psql &> /dev/null; then
    echo -e "${RED}❌ PostgreSQL is not installed!${NC}"
    echo -e "${YELLOW}Install PostgreSQL: sudo apt-get install postgresql postgresql-contrib${NC}"
    exit 1
fi
echo -e "${GREEN}✅ PostgreSQL found${NC}\n"

# Check if Node.js is installed
echo -e "${YELLOW}[2/6] Checking Node.js...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed!${NC}"
    echo -e "${YELLOW}Install Node.js: https://nodejs.org/${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Node.js $(node -v) found${NC}\n"

# Check if Flutter is installed
echo -e "${YELLOW}[3/6] Checking Flutter...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed!${NC}"
    echo -e "${YELLOW}Install Flutter: https://flutter.dev/docs/get-started/install${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Flutter $(flutter --version | head -n 1) found${NC}\n"

# Setup Backend
echo -e "${YELLOW}[4/6] Setting up Backend...${NC}"
cd backend

# Create .env file if not exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✅ .env file created. Please update with your database credentials.${NC}"
fi

# Install dependencies
echo -e "${YELLOW}Installing Node.js dependencies...${NC}"
npm install
echo -e "${GREEN}✅ Backend dependencies installed${NC}\n"

# Setup database
echo -e "${YELLOW}Setting up database...${NC}"
read -p "$(echo -e ${YELLOW}Enter PostgreSQL username [default: postgres]: ${NC})" DB_USER
DB_USER=${DB_USER:-postgres}

read -p "$(echo -e ${YELLOW}Enter PostgreSQL password: ${NC})" -s DB_PASSWORD
echo ""

read -p "$(echo -e ${YELLOW}Enter database name [default: avtohelp]: ${NC})" DB_NAME
DB_NAME=${DB_NAME:-avtohelp}

# Create database
echo -e "${YELLOW}Creating database...${NC}"
PGPASSWORD=$DB_PASSWORD createdb -U $DB_USER $DB_NAME 2>/dev/null || echo -e "${YELLOW}Database already exists${NC}"

# Enable PostGIS extension
echo -e "${YELLOW}Enabling PostGIS extension...${NC}"
PGPASSWORD=$DB_PASSWORD psql -U $DB_USER -d $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS postgis;" 2>/dev/null || true

# Update .env with database credentials
echo -e "${YELLOW}Updating .env with database credentials...${NC}"
sed -i "s/DB_USER=.*/DB_USER=$DB_USER/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" .env
sed -i "s/DB_NAME=.*/DB_NAME=$DB_NAME/" .env

# Run migrations
echo -e "${YELLOW}Running database migrations...${NC}"
npm run migrate
echo -e "${GREEN}✅ Database setup complete${NC}\n"

cd ..

# Setup Mobile
echo -e "${YELLOW}[5/6] Setting up Mobile...${NC}"
cd mobile

# Get Flutter dependencies
echo -e "${YELLOW}Getting Flutter dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✅ Flutter dependencies installed${NC}\n"

cd ..

# Final instructions
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   ✅ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}Next steps:${NC}"
echo -e "${YELLOW}1.${NC} Start the backend:    ${GREEN}cd backend && npm start${NC}"
echo -e "${YELLOW}2.${NC} Start the mobile app: ${GREEN}cd mobile && flutter run${NC}"
echo -e "${YELLOW}3.${NC} Or use quick start:   ${GREEN}./start.sh${NC}\n"

echo -e "${BLUE}Demo login credentials:${NC}"
echo -e "  Phone: ${GREEN}+998901234567${NC}"
echo -e "  Password: ${GREEN}password123${NC}\n"

echo -e "${YELLOW}Happy coding! 🚀${NC}\n"
