#!/bin/bash

echo "🚀 FarmLink Backend Setup"
echo "========================="
echo ""

# Check if package-lock.json exists
if [ ! -f "package-lock.json" ]; then
    echo "📦 Generando package-lock.json..."
    npm install --package-lock-only
    echo "✅ package-lock.json generado"
else
    echo "✅ package-lock.json ya existe"
fi

echo ""
echo "🐳 Iniciando Docker Compose..."
docker compose up --build

echo ""
echo "✨ Setup completado!"
