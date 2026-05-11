> **ATENCIÓN (Fase 0 — saneamiento):** Este documento describe una arquitectura planificada
> (Prisma + JWT + rutas `/api/v1/`) que **NO corresponde al código actual**. El backend real
> usa TypeORM con rutas en español (`/usuarios/login`, `/alimentos`). Ver `CLAUDE.md` y
> `PLAN_DE_TRABAJO.md` para el estado real del proyecto.

# 🧪 Guía de Pruebas - FarmLink API

Esta guía te ayudará a probar todos los endpoints de la API paso a paso.

## 📋 Prerequisitos

- Backend corriendo en http://localhost:3000
- Herramienta de pruebas (elige una):
  - **Swagger UI** (Recomendado para principiantes): http://localhost:3000/api/docs
  - **curl** (Línea de comandos)
  - **Postman** o **Insomnia**
  - **Thunder Client** (extensión de VS Code)

---

## 🚀 Flujo de Prueba Completo

### **Paso 1: Verificar que la API esté funcionando**

```bash
# Opción 1: Acceder a Swagger
# Abre en tu navegador: http://localhost:3000/api/docs

# Opción 2: curl
curl http://localhost:3000/api/v1/auth/login
# Deberías ver un error 400 (es normal, significa que la API responde)
```

---

### **Paso 2: Crear un Tenant**

**IMPORTANTE**: Primero necesitas crear un tenant antes de registrar usuarios.

#### Con Swagger:
1. Ve a http://localhost:3000/api/docs
2. Expande `Tenants > POST /api/v1/tenants`
3. Click en "Try it out"
4. Usa este JSON:

```json
{
  "name": "Mi Empresa Agrícola",
  "email": "empresa@farmlink.com",
  "phone": "+1234567890",
  "address": "123 Farm Street, Agriculture City"
}
```

5. Click "Execute"
6. **IMPORTANTE**: Copia el `id` del tenant de la respuesta

#### Con curl:

```bash
curl -X POST http://localhost:3000/api/v1/tenants \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Mi Empresa Agrícola",
    "email": "empresa@farmlink.com",
    "phone": "+1234567890",
    "address": "123 Farm Street, Agriculture City"
  }'
```

**Respuesta esperada:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Mi Empresa Agrícola",
  "email": "empresa@farmlink.com",
  ...
}
```

**⚠️ Guarda el `id` del tenant!** Lo necesitarás para el siguiente paso.

---

### **Paso 3: Registrar un Usuario**

Usa el `tenantId` del paso anterior.

#### Con Swagger:
1. Ve a `Authentication > POST /api/v1/auth/register`
2. Click "Try it out"
3. Usa este JSON (reemplaza `TENANT_ID_AQUI`):

```json
{
  "email": "admin@farmlink.com",
  "password": "Password123!",
  "firstName": "Juan",
  "lastName": "Pérez",
  "phone": "+1234567890",
  "tenantId": "TENANT_ID_AQUI"
}
```

#### Con curl:

```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@farmlink.com",
    "password": "Password123!",
    "firstName": "Juan",
    "lastName": "Pérez",
    "phone": "+1234567890",
    "tenantId": "TENANT_ID_AQUI"
  }'
```

**Respuesta esperada:**
```json
{
  "user": {
    "id": "uuid-del-usuario",
    "email": "admin@farmlink.com",
    ...
  },
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**⚠️ Guarda el `accessToken`!** Lo necesitarás para las siguientes peticiones.

---

### **Paso 4: Iniciar Sesión (Login)**

#### Con Swagger:
1. Ve a `Authentication > POST /api/v1/auth/login`
2. Click "Try it out"
3. Usa este JSON:

```json
{
  "email": "admin@farmlink.com",
  "password": "Password123!"
}
```

#### Con curl:

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@farmlink.com",
    "password": "Password123!"
  }'
```

**Respuesta esperada:** Igual que el registro, recibirás `accessToken` y `refreshToken`.

---

### **Paso 5: Usar Endpoints Protegidos**

Ahora que tienes un `accessToken`, puedes acceder a endpoints protegidos.

#### Configurar Autenticación en Swagger:
1. Click en el botón **"Authorize"** (candado arriba a la derecha)
2. Ingresa: `Bearer TU_ACCESS_TOKEN_AQUI`
3. Click "Authorize"
4. Ahora todos los endpoints protegidos funcionarán

#### Listar Usuarios

**Con Swagger:**
1. Ve a `Users > GET /api/v1/users`
2. Click "Try it out"
3. Click "Execute"

**Con curl:**

```bash
curl -X GET http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer TU_ACCESS_TOKEN_AQUI"
```

#### Obtener Usuario por ID

```bash
curl -X GET http://localhost:3000/api/v1/users/ID_DEL_USUARIO \
  -H "Authorization: Bearer TU_ACCESS_TOKEN_AQUI"
```

#### Listar Tenants

```bash
curl -X GET http://localhost:3000/api/v1/tenants \
  -H "Authorization: Bearer TU_ACCESS_TOKEN_AQUI"
```

---

### **Paso 6: Refrescar Token**

Los access tokens expiran en 15 minutos. Para obtener uno nuevo sin hacer login:

```bash
curl -X POST http://localhost:3000/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "TU_REFRESH_TOKEN_AQUI"
  }'
```

---

### **Paso 7: Cerrar Sesión**

```bash
curl -X POST http://localhost:3000/api/v1/auth/logout \
  -H "Authorization: Bearer TU_ACCESS_TOKEN_AQUI"
```

---

## 🎯 Casos de Prueba Completos

### **Caso 1: Flujo de Usuario Nuevo**

```bash
# 1. Crear tenant
TENANT_RESPONSE=$(curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Finca Los Pinos",
    "email": "lospinos@farm.com"
  }')

# 2. Extraer tenantId (manual o con jq)
TENANT_ID="id-del-tenant-de-la-respuesta"

# 3. Registrar usuario
REGISTER_RESPONSE=$(curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "farmer@lospinos.com",
    "password": "Secure123!",
    "firstName": "Carlos",
    "lastName": "Ramírez",
    "tenantId": "'$TENANT_ID'"
  }')

# 4. Extraer accessToken
ACCESS_TOKEN="token-de-la-respuesta"

# 5. Listar usuarios
curl -X GET http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

### **Caso 2: Gestión de Usuarios**

```bash
# Crear usuario adicional
curl -X POST http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "empleado@lospinos.com",
    "password": "Password123!",
    "firstName": "María",
    "lastName": "González",
    "tenantId": "'$TENANT_ID'"
  }'

# Actualizar usuario
curl -X PATCH http://localhost:3000/api/v1/users/USER_ID \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "María José",
    "phone": "+573001234567"
  }'

# Eliminar usuario (soft delete)
curl -X DELETE http://localhost:3000/api/v1/users/USER_ID \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

---

## ❌ Errores Comunes

### Error 401 Unauthorized
```json
{
  "statusCode": 401,
  "message": "Invalid token or user not found"
}
```
**Solución**: Verifica que tu token sea correcto y no haya expirado (15 min).

### Error 404 Not Found
```json
{
  "statusCode": 404,
  "message": "Cannot GET /api/v1/endpoint"
}
```
**Solución**: Verifica la URL. Recuerda que la base es `/api/v1/`

### Error 409 Conflict
```json
{
  "statusCode": 409,
  "message": "User with this email already exists"
}
```
**Solución**: El email ya está registrado. Usa otro email.

### Error 400 Bad Request
```json
{
  "statusCode": 400,
  "message": ["email must be an email"]
}
```
**Solución**: Revisa que los datos del request cumplan con las validaciones.

---

## 🔐 Notas de Seguridad

- **Access Token**: Expira en 15 minutos
- **Refresh Token**: Expira en 7 días
- Contraseñas hasheadas con bcrypt
- JWT firmado con secreto

---

## 📊 Resumen de Endpoints

| Método | Endpoint | Auth | Descripción |
|--------|----------|------|-------------|
| POST | /api/v1/auth/register | ❌ | Registrar usuario |
| POST | /api/v1/auth/login | ❌ | Iniciar sesión |
| POST | /api/v1/auth/refresh | ❌ | Refrescar token |
| POST | /api/v1/auth/logout | ✅ | Cerrar sesión |
| GET | /api/v1/users | ✅ | Listar usuarios |
| POST | /api/v1/users | ✅ | Crear usuario |
| GET | /api/v1/users/:id | ✅ | Obtener usuario |
| PATCH | /api/v1/users/:id | ✅ | Actualizar usuario |
| DELETE | /api/v1/users/:id | ✅ | Eliminar usuario |
| GET | /api/v1/tenants | ✅ | Listar tenants |
| POST | /api/v1/tenants | ✅ | Crear tenant |
| GET | /api/v1/tenants/:id | ✅ | Obtener tenant |
| PATCH | /api/v1/tenants/:id | ✅ | Actualizar tenant |
| DELETE | /api/v1/tenants/:id | ✅ | Eliminar tenant |

---

## 🎉 ¡Listo!

Ahora conoces todos los endpoints y cómo probarlos. Te recomiendo usar **Swagger UI** en http://localhost:3000/api/docs para una experiencia más visual y fácil.
