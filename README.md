# FarmLink 

Backend API profesional construido con NestJS, TypeScript, Prisma y PostgreSQL.

## 🚀 Tecnologías

- **NestJS** - Framework progresivo de Node.js
- **TypeScript** - JavaScript con tipado estático
- **Prisma** - ORM de próxima generación
- **PostgreSQL 16** - Base de datos relacional
- **JWT** - Autenticación basada en tokens
- **bcrypt** - Hashing de contraseñas
- **Swagger** - Documentación de API
- **Docker** - Contenedorización

## 📋 Características

- ✅ Arquitectura modular escalable
- ✅ Autenticación JWT (Access + Refresh tokens)
- ✅ Multi-tenant con relaciones
- ✅ Soft delete en modelos
- ✅ Guard global JWT
- ✅ Decorador @CurrentUser
- ✅ Documentación Swagger automática
- ✅ Versionado de API (v1)
- ✅ Validación de DTOs
- ✅ Variables de entorno
- ✅ Docker ready

## 🏗️ Estructura del Proyecto

```
farmlink-backend/
├── src/
│   ├── config/              # Configuraciones
│   ├── common/              # Recursos compartidos
│   │   ├── decorators/      # Decoradores personalizados
│   │   └── guards/          # Guards de autenticación
│   ├── modules/
│   │   ├── auth/            # Módulo de autenticación
│   │   ├── users/           # Módulo de usuarios
│   │   └── tenants/         # Módulo de tenants
│   ├── prisma/              # Servicio de Prisma
│   ├── app.module.ts
│   └── main.ts
├── prisma/
│   └── schema.prisma        # Esquema de base de datos
├── docker-compose.yml
├── Dockerfile
└── package.json
```

## 🐳 Inicio Rápido con Docker

### Prerrequisitos
- Docker
- Docker Compose

### Levantar el proyecto

```bash
# Clonar el repositorio (si aplica)
cd farmlink-backend

# OPCIÓN 1: Usando el script de setup (Recomendado)
chmod +x setup.sh
./setup.sh

# OPCIÓN 2: Manual
# Construir y levantar los servicios
docker compose up --build

# Para ejecutar en segundo plano
docker compose up -d --build
```

**Nota**: 
- El Dockerfile está optimizado para funcionar sin package-lock.json, usando `npm install` en su lugar.
- PostgreSQL usa el puerto **5433** en el host (para evitar conflictos con instalaciones locales), pero **5432** internamente en Docker.

La API estará disponible en:
- **API**: http://localhost:3000/api/v1
- **Swagger**: http://localhost:3000/api/docs
- **PostgreSQL**: localhost:5433 (desde tu máquina)
- **Health Check**: http://localhost:3000/api/v1/auth/login (endpoint público)

### Comandos útiles de Docker

```bash
# Ver logs
docker compose logs -f backend

# Detener servicios
docker compose down

# Detener y eliminar volúmenes
docker compose down -v

# Reconstruir solo el backend
docker compose up --build backend
```

## 💻 Desarrollo Local (sin Docker)

### Prerrequisitos
- Node.js 20+
- PostgreSQL 16
- npm o yarn

### Instalación

```bash
# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus valores

# Generar cliente de Prisma
npm run prisma:generate

# Ejecutar migraciones
npm run prisma:migrate

# Iniciar en modo desarrollo
npm run start:dev
```

## 🗄️ Base de Datos

### Modelos

#### Tenant
- Multi-tenancy support
- Soft delete
- Relación 1:N con Users

#### User
- Autenticación JWT
- Roles: SUPER_ADMIN, ADMIN, USER
- Soft delete
- Relación N:1 con Tenant

### Migraciones de Prisma

```bash
# Crear una nueva migración
npx prisma migrate dev --name nombre_migracion

# Aplicar migraciones en producción
npx prisma migrate deploy

# Abrir Prisma Studio
npm run prisma:studio
```

## 🔐 Autenticación

El sistema utiliza JWT con dos tipos de tokens:

- **Access Token**: Expira en 15 minutos
- **Refresh Token**: Expira en 7 días

### Endpoints de Autenticación

```bash
POST /api/v1/auth/register    # Registrar usuario
POST /api/v1/auth/login       # Iniciar sesión
POST /api/v1/auth/refresh     # Refrescar token
POST /api/v1/auth/logout      # Cerrar sesión
```

### Ejemplo de uso

```bash
# Registro
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "Password123!",
    "firstName": "John",
    "lastName": "Doe",
    "tenantId": "uuid-del-tenant"
  }'

# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "Password123!"
  }'

# Usar el token
curl -X GET http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## 📚 Documentación API

La documentación completa de la API está disponible en Swagger:

**URL**: http://localhost:3000/api/docs

### Rutas Importantes

```
BASE_URL: http://localhost:3000

├── /api/docs                    → Documentación Swagger
├── /api/v1/                     → Base de la API v1
│   ├── auth/
│   │   ├── POST /register       → Registrar usuario
│   │   ├── POST /login          → Iniciar sesión
│   │   ├── POST /refresh        → Refrescar token
│   │   └── POST /logout         → Cerrar sesión (requiere auth)
│   ├── users/
│   │   ├── GET    /             → Listar usuarios (requiere auth)
│   │   ├── POST   /             → Crear usuario (requiere auth)
│   │   ├── GET    /:id          → Obtener usuario (requiere auth)
│   │   ├── PATCH  /:id          → Actualizar usuario (requiere auth)
│   │   └── DELETE /:id          → Eliminar usuario (requiere auth)
│   └── tenants/
│       ├── GET    /             → Listar tenants (requiere auth)
│       ├── POST   /             → Crear tenant (requiere auth)
│       ├── GET    /:id          → Obtener tenant (requiere auth)
│       ├── PATCH  /:id          → Actualizar tenant (requiere auth)
│       └── DELETE /:id          → Eliminar tenant (requiere auth)
```

Swagger incluye:
- Todos los endpoints
- Esquemas de request/response
- Autenticación Bearer
- Prueba directa de endpoints

## 🛡️ Seguridad

- ✅ Hashing de contraseñas con bcrypt
- ✅ JWT para autenticación stateless
- ✅ Guard global para proteger rutas
- ✅ Refresh tokens con rotación
- ✅ Validación de DTOs
- ✅ CORS habilitado

## 🔧 Variables de Entorno

```env
# Application
PORT=3000
NODE_ENV=development
API_VERSION=v1

# Database
DATABASE_URL=postgresql://postgres:postgres@db:5432/farmlink

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_REFRESH_SECRET=your-super-secret-refresh-jwt-key-change-this-in-production
JWT_EXPIRATION=15m
JWT_REFRESH_EXPIRATION=7d

# Swagger
SWAGGER_ENABLED=true
SWAGGER_PATH=api/docs
```

## 📦 Scripts Disponibles

```bash
npm run build              # Compilar proyecto
npm run start              # Iniciar aplicación
npm run start:dev          # Modo desarrollo con hot-reload
npm run start:prod         # Modo producción
npm run lint               # Ejecutar ESLint
npm run format             # Formatear código
npm run prisma:generate    # Generar cliente Prisma
npm run prisma:migrate     # Ejecutar migraciones
npm run prisma:studio      # Abrir Prisma Studio
```

## 🚀 Próximos Pasos

Esta es la base estructural del backend. Para agregar funcionalidad de negocio:

1. Crear nuevos módulos en `src/modules/`
2. Definir modelos en `prisma/schema.prisma`
3. Ejecutar migraciones
4. Implementar servicios, controladores y DTOs
5. Documentar con decoradores de Swagger

## 📝 Notas de Producción

- Cambiar `JWT_SECRET` y `JWT_REFRESH_SECRET` por valores seguros
- Configurar `NODE_ENV=production`
- Implementar rate limiting
- Configurar logs apropiados
- Usar variables de entorno secretas
- Configurar CORS apropiadamente
- Implementar monitoreo y alertas

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama feature (`git checkout -b feature/nueva-caracteristica`)
3. Commit tus cambios (`git commit -m 'Agregar nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Abre un Pull Request

## 📄 Licencia

MIT
