# 🐄 PLATAFORMA-GANADERA-MULTITENANT – FarmLink

[<img src="https://img.icons8.com/?size=512&id=119635&format=png" align="right" width="25%">]()

# FARMLINK

#### Plataforma Inteligente de Gestión Ganadera Multitenant

<p align="left">
	<img src="https://img.shields.io/github/license/ISCOUTB/plataforma-ganadera-multitenant?style=social&logo=opensourceinitiative&color=00ff1b" />
	<img src="https://img.shields.io/github/last-commit/ISCOUTB/plataforma-ganadera-multitenant?style=social&logo=git&color=00ff1b" />
	<img src="https://img.shields.io/github/languages/top/ISCOUTB/plataforma-ganadera-multitenant?style=social&color=00ff1b" />
	<img src="https://img.shields.io/github/languages/count/ISCOUTB/plataforma-ganadera-multitenant?style=social&color=00ff1b" />
</p>

<p align="center">
	<em>Construido con las siguientes tecnologías:</em>
</p>

<p align="center">
	<img src="https://img.shields.io/badge/NestJS-E0234E.svg?style=social&logo=nestjs&logoColor=white" />
	<img src="https://img.shields.io/badge/Prisma-2D3748.svg?style=social&logo=prisma&logoColor=white" />
	<img src="https://img.shields.io/badge/PostgreSQL-4169E1.svg?style=social&logo=postgresql&logoColor=white" />
	<img src="https://img.shields.io/badge/Docker-2496ED.svg?style=social&logo=docker&logoColor=white" />
	<img src="https://img.shields.io/badge/Node.js-339933.svg?style=social&logo=node.js&logoColor=white" />
</p>

---

## 🔗 Tabla de Contenidos

- [📍 Descripción General](#-descripción-general)
- [🏗 Arquitectura](#-arquitectura)
- [👾 Características](#-características)
- [📂 Estructura del Repositorio](#-estructura-del-repositorio)
- [🧩 Módulos del Sistema](#-módulos-del-sistema)
- [🚀 Primeros Pasos](#-primeros-pasos)
    - [🔖 Prerrequisitos](#-prerrequisitos)
    - [📦 Instalación](#-instalación)
    - [🐳 Ejecución con Docker](#-ejecución-con-docker)
    - [📡 Endpoints](#-endpoints)
- [🔐 Seguridad](#-seguridad)
- [📱 Arquitectura Móvil](#-arquitectura-móvil)
- [🎓 Proyecto Académico](#-proyecto-académico)
- [🎗 Licencia](#-licencia)



## 📍 Descripción General

**FarmLink** es una plataforma digital multitenant diseñada para optimizar la gestión integral de explotaciones ganaderas.

El sistema permite administrar:

- Hato ganadero
- Salud animal
- Nutrición
- Reproducción
- Potreros
- Finanzas
- Usuarios y roles
- Reportes estratégicos

Está diseñado bajo una arquitectura escalable en la nube, orientada al contexto rural colombiano y alineada con estándares de trazabilidad y control productivo.

---

## 🏗 Arquitectura

Arquitectura basada en:

- Backend API REST con **NestJS**
- ORM moderno con **Prisma**
- Base de datos **PostgreSQL 16**
- Contenedores **Docker**
- Autenticación con **JWT**
- Arquitectura modular y escalable
- Soporte **multitenant**

### Flujo Arquitectónico

Cliente (Web / Móvil)  
⬇  
API REST (NestJS)  
⬇  
Prisma ORM  
⬇  
PostgreSQL  

---

## 👾 Características

- 🔐 Autenticación y autorización con JWT
- 🏢 Soporte Multitenant (múltiples fincas/empresas)
- 👥 Gestión de usuarios y roles
- 🐄 Gestión de animales
- 💉 Registro de eventos de salud
- 🌱 Control de nutrición
- 📊 Reportes y métricas productivas
- 🐳 Entorno dockerizado profesional
- 📦 Versionado de API (`/api/v1`)
- 📈 Arquitectura preparada para crecimiento

---

## 📂 Estructura del Repositorio

```bash
plataforma-ganadera-multitenant/
│
├── docker-compose.yml
├── Dockerfile
├── package.json
├── prisma/
│   ├── schema.prisma
│   └── migrations/
├── src/
│   ├── main.ts
│   ├── app.module.ts
│   ├── auth/
│   ├── users/
│   ├── tenants/
│   ├── prisma/
│   └── common/
└── README.md
````

---

## 🧩 Módulos del Sistema

### 🔐 Auth Module

* Registro de usuarios
* Login
* Refresh Token
* Logout
* Protección con JWT

### 👤 Users Module

* Crear usuario
* Listar usuarios
* Actualizar usuario
* Eliminar usuario

### 🏢 Tenants Module

* Crear empresa/finca
* Gestión por tenant
* Aislamiento lógico de datos

### 🗄 Prisma Module

* Conexión a base de datos
* Gestión de migraciones
* Cliente ORM

---

## 🚀 Primeros Pasos

### 🔖 Prerrequisitos

* Node.js ≥ 20
* Docker y Docker Compose
* Git
* Linux / macOS / Windows

---

### 📦 Instalación

Clonar repositorio:

```bash
git clone https://github.com/ISCOUTB/plataforma-ganadera-multitenant.git
cd plataforma-ganadera-multitenant
```

Instalar dependencias:

```bash
npm install
```

---

### 🐳 Ejecución con Docker

```bash
docker compose up --build
```

La aplicación estará disponible en:

```
http://localhost:3000/api/v1
```

---

### 📡 Endpoints Principales

#### Auth

```
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/refresh
POST /api/v1/auth/logout
```

#### Users

```
GET /api/v1/users
POST /api/v1/users
PATCH /api/v1/users/:id
DELETE /api/v1/users/:id
```

#### Tenants

```
GET /api/v1/tenants
POST /api/v1/tenants
GET /api/v1/tenants/:id
PATCH /api/v1/tenants/:id
DELETE /api/v1/tenants/:id
```

---

## 🔐 Seguridad

* JWT Access & Refresh Tokens
* Encriptación de contraseñas con bcrypt
* Validación de DTOs
* Aislamiento por tenant
* Variables de entorno protegidas
* Contenedores seguros

---

## 📱 Arquitectura Móvil

El backend está diseñado para soportar:

* Aplicación móvil Flutter
* Cliente Web (React / Next.js)
* Comunicación vía REST API
* Versionado para futuras actualizaciones
* Arquitectura escalable en la nube

---

## 🎓 Proyecto Académico

Este sistema forma parte del proyecto universitario:

**Proyecto de Ingeniería – Plataforma Multitenant Ganadera**

Objetivos del proyecto:

* Aplicar arquitectura limpia y modular
* Implementar un sistema escalable real
* Resolver problemática productiva rural
* Integrar backend profesional dockerizado
* Diseñar arquitectura preparada para entorno móvil

---

## 🎗 Licencia

Este proyecto está protegido bajo la licencia MIT.

---

