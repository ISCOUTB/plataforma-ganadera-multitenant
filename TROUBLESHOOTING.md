> **ATENCIÓN (Fase 0 — saneamiento):** Este documento describe problemas de una arquitectura
> planificada (Prisma + Docker multi-servicio) que **NO corresponde al código actual**. El
> backend real es NestJS con TypeORM. Para el estado real del proyecto ver `CLAUDE.md` y
> `PLAN_DE_TRABAJO.md`.

# 🔧 Solución de Problemas

## Error: "npm ci" can only install with an existing package-lock.json

### Causa
El comando `npm ci` requiere un archivo `package-lock.json` que no estaba incluido en el proyecto inicial.

### Solución
El Dockerfile ha sido actualizado para usar `npm install` en lugar de `npm ci`, lo que funciona sin package-lock.json.

**Ejecuta:**
```bash
docker compose up --build
```

### Solución Alternativa (Generar package-lock.json)
Si prefieres usar `npm ci` (más rápido en builds subsecuentes):

```bash
# Generar package-lock.json localmente
npm install --package-lock-only

# Luego construir Docker
docker compose up --build
```

---

## Warning: "the attribute version is obsolete"

### Causa
Docker Compose versión 2.x deprecó el campo `version` en docker-compose.yml.

### Solución
Ya está corregido. El `version: '3.8'` ha sido removido del archivo.

---

## Puerto 3000 ya en uso

### Solución
```bash
# Opción 1: Detener el proceso que usa el puerto
sudo lsof -i :3000
sudo kill -9 <PID>

# Opción 2: Cambiar el puerto en docker-compose.yml
# En la sección backend > ports, cambia:
    ports:
      - "3001:3000"  # Usa puerto 3001 en tu máquina
```

---

## Puerto 5432 (PostgreSQL) ya en uso

### Solución
```bash
# Opción 1: Detener PostgreSQL local
sudo systemctl stop postgresql

# Opción 2: Cambiar el puerto en docker-compose.yml
# En la sección db > ports, cambia:
    ports:
      - "5433:5432"  # Usa puerto 5433 en tu máquina
```

---

## Error de permisos en volúmenes

### Solución
```bash
# Dar permisos al directorio de volúmenes
sudo chown -R $USER:$USER ./

# O limpiar volúmenes y reiniciar
docker compose down -v
docker compose up --build
```

---

## Error: "Cannot connect to database"

### Verificar
```bash
# Ver logs del contenedor de base de datos
docker compose logs db

# Verificar que el contenedor esté corriendo
docker compose ps
```

### Solución
```bash
# Reiniciar servicios
docker compose down
docker compose up --build

# Si persiste, limpiar volúmenes
docker compose down -v
docker compose up --build
```

---

## Prisma: Error de conexión

### Verificar DATABASE_URL
Asegúrate de que en `.env` o en `docker-compose.yml` esté:
```
DATABASE_URL=postgresql://postgres:postgres@db:5432/farmlink
```

**Importante**: El host debe ser `db` (nombre del servicio) no `localhost` dentro de Docker.

---

## Rebuilds lentos

### Optimización
```bash
# Usar cache de Docker
docker compose build --no-cache  # Solo si hay problemas

# Limpiar imágenes antiguas
docker image prune -a

# Para desarrollo local sin Docker
npm install
npm run start:dev
```

---

## Ver logs en tiempo real

```bash
# Todos los servicios
docker compose logs -f

# Solo backend
docker compose logs -f backend

# Solo database
docker compose logs -f db
```

---

## Resetear completamente el proyecto

```bash
# Detener y eliminar todo
docker compose down -v
docker system prune -a --volumes

# Volver a construir
docker compose up --build
```

---

## Ejecutar migraciones manualmente

```bash
# Entrar al contenedor
docker compose exec backend sh

# Dentro del contenedor
npx prisma migrate dev
npx prisma migrate deploy
npx prisma studio  # Abre interfaz visual
```

---

## Variables de entorno no se cargan

### Verificar
1. Archivo `.env` existe en la raíz
2. Las variables están en `docker-compose.yml` en la sección `environment`

### Recrear contenedores
```bash
docker compose down
docker compose up --build
```

---

## Necesitas acceso a PostgreSQL directamente

```bash
# Opción 1: Desde otro contenedor
docker compose exec db psql -U postgres -d farmlink

# Opción 2: Desde tu máquina (si puerto 5432 está expuesto)
psql -h localhost -U postgres -d farmlink
# Password: postgres
```

---

## Contacto y Soporte

Si el problema persiste:
1. Revisa los logs: `docker compose logs -f`
2. Verifica que todos los archivos estén presentes
3. Asegúrate de tener Docker y Docker Compose actualizados
4. Prueba con `docker compose down -v && docker compose up --build`
