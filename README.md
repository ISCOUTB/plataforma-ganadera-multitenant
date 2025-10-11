# Plataforma Ganadera Backend

Sistema multitenant para gestión ganadera con NestJS + PostgreSQL + TypeORM

## 🚀 Inicio Rápido

### Requisitos
- Node.js 18+
- PostgreSQL 15+
- npm/yarn

### Instalación
```bash
# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env

# Iniciar base de datos (Docker)
docker-compose up -d

# Ejecutar migraciones
npm run migration:run

# Iniciar aplicación
npm run dev
```

## 📚 Documentación API

http://localhost:3000/docs

## 🧪 Testing
```bash
npm run test
npm run test:e2e
npm run test:cov
```

## 🏗️ Scripts

- `npm run dev` - Desarrollo
- `npm run build` - Compilar
- `npm run start:prod` - Producción
- `npm run migration:generate` - Generar migración
- `npm run migration:run` - Ejecutar migraciones