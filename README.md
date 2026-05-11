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
	<img src="https://img.shields.io/badge/TypeScript-3178C6.svg?style=social&logo=typescript&logoColor=white" />
	<img src="https://img.shields.io/badge/Flutter-02569B.svg?style=social&logo=flutter&logoColor=white" />
	<img src="https://img.shields.io/badge/Dart-0175C2.svg?style=social&logo=dart&logoColor=white" />
	<img src="https://img.shields.io/badge/Node.js-339933.svg?style=social&logo=node.js&logoColor=white" />
</p>

---

## 🔗 Tabla de Contenidos

- [📍 Descripción General](#-descripción-general)
- [🏗 Arquitectura](#-arquitectura)
- [👾 Características](#-características)
- [📂 Estructura del Repositorio](#-estructura-del-repositorio)
- [🧩 Módulos del Sistema](#-módulos-del-sistema)
- [📱 Frontend Móvil y Multiplataforma](#-frontend-móvil-y-multiplataforma)
- [🚀 Primeros Pasos](#-primeros-pasos)
  - [🔖 Prerrequisitos](#-prerrequisitos)
  - [📦 Instalación](#-instalación)
  - [⚙ Ejecución del Backend](#-ejecución-del-backend)
  - [📲 Ejecución del Frontend](#-ejecución-del-frontend)
- [🎓 Proyecto Académico](#-proyecto-académico)
- [🎗 Licencia](#-licencia)

---

## 📍 Descripción General

**FarmLink** es una plataforma digital orientada a la gestión ganadera, organizada como un proyecto multitenant con separación entre backend y frontend.

El sistema está diseñado para apoyar procesos como:

- Gestión de animales
- Administración de fincas
- Control de potreros
- Registro de salud animal
- Seguimiento de reproducción
- Gestión de alimentos
- Control financiero
- Administración de usuarios

La solución está dividida en una API backend desarrollada con NestJS y una aplicación frontend desarrollada en Flutter.

---

## 🏗 Arquitectura

La arquitectura actual del proyecto está organizada en dos grandes capas:

- **Backend** con NestJS, TypeScript y Prisma
- **Frontend** con Flutter y Dart
- Estructura modular por dominios funcionales
- Separación entre lógica de negocio, servicios y entidades
- Base preparada para crecimiento y mantenimiento

### Flujo Arquitectónico

Cliente Flutter  
⬇  
API Backend (NestJS)  
⬇  
Servicios y módulos  
⬇  
Prisma ORM  
⬇  
Base de datos  

---

## 👾 Características

- 🐄 Gestión modular del dominio ganadero
- 🏡 Administración de fincas y potreros
- 💉 Registro de salud animal
- 🌱 Control de alimentos
- 🔬 Seguimiento de reproducción
- 💰 Gestión financiera
- 👤 Administración de usuarios
- 📱 Frontend multiplataforma con Flutter
- 🧩 Organización por módulos y entidades
- 📦 Repositorio dividido en Backend y Frontend

---

## 📂 Estructura del Repositorio

```bash
plataforma-ganadera-multitenant/
│
├── Backend/
│   ├── prisma/
│   │   ├── schema.prisma
│   │   └── schema.prisma.bak
│   ├── src/
│   │   ├── alimentos/
│   │   │   ├── entities/
│   │   │   │   └── alimento.entity.ts
│   │   │   ├── alimentos.controller.ts
│   │   │   ├── alimentos.module.ts
│   │   │   └── alimentos.service.ts
│   │   ├── animales/
│   │   │   ├── entities/
│   │   │   │   └── animal.entity.ts
│   │   │   ├── animales.module.ts
│   │   │   └── animales.service.ts
│   │   ├── bovino-alimento/
│   │   │   └── entities/
│   │   │       └── bovino-alimento.entity.ts
│   │   ├── finanzas/
│   │   │   ├── entities/
│   │   │   │   └── finanza.entity.ts
│   │   │   ├── finanzas.controller.ts
│   │   │   ├── finanzas.module.ts
│   │   │   └── finanzas.service.ts
│   │   ├── fincas/
│   │   │   ├── entities/
│   │   │   │   └── finca.entity.ts
│   │   │   ├── fincas.module.ts
│   │   │   └── fincas.service.ts
│   │   ├── potreros/
│   │   │   ├── entities/
│   │   │   │   └── potrero.entity.ts
│   │   │   ├── potreros.module.ts
│   │   │   └── potreros.service.ts
│   │   ├── reproduccion/
│   │   │   ├── entities/
│   │   │   │   └── reproduccion.entity.ts
│   │   │   ├── reproduccion.controller.ts
│   │   │   ├── reproduccion.module.ts
│   │   │   └── reproduccion.service.ts
│   │   ├── salud/
│   │   │   ├── entities/
│   │   │   │   └── salud.entity.ts
│   │   │   ├── salud.controller.ts
│   │   │   ├── salud.module.ts
│   │   │   └── salud.service.ts
│   │   ├── usuarios/
│   │   │   ├── entities/
│   │   │   │   └── usuario.entity.ts
│   │   │   ├── usuarios.controller.ts
│   │   │   ├── usuarios.module.ts
│   │   │   └── usuarios.service.ts
│   │   ├── app.controller.spec.ts
│   │   ├── app.controller.ts
│   │   ├── app.module.ts
│   │   ├── app.service.ts
│   │   └── main.ts
│   ├── test/
│   │   ├── app.e2e-spec.ts
│   │   └── jest-e2e.json
│   ├── .gitignore
│   ├── .prettierrc
│   ├── eslint.config.mjs
│   ├── nest-cli.json
│   ├── package.json
│   ├── package-lock.json
│   ├── tsconfig.build.json
│   ├── tsconfig.json
│   └── README.md
│
├── Frontend/
│   ├── assets/
│   │   ├── Logo.png
│   │   ├── about_us.jpeg
│   │   └── farm_hero.jpeg
│   ├── lib/
│   │   ├── components/
│   │   │   ├── input_field.dart
│   │   │   └── primary_button.dart
│   │   ├── screens/
│   │   │   ├── Dashboard_screen.dart
│   │   │   ├── Landing_screen.dart
│   │   │   ├── Login_screen.dart
│   │   │   └── Registro_screen.dart
│   │   ├── services/
│   │   │   └── api_service.dart
│   │   ├── theme/
│   │   │   ├── Colors.dart
│   │   │   ├── Theme.dart
│   │   │   └── colors.dart
│   │   └── main.dart
│   ├── android/
│   ├── ios/
│   ├── linux/
│   ├── macos/
│   ├── web/
│   ├── windows/
│   ├── test/
│   │   └── widget_test.dart
│   ├── .gitignore
│   ├── .metadata
│   ├── analysis_options.yaml
│   ├── pubspec.yaml
│   ├── pubspec.lock
│   └── README.md
│
└── README.md
```

---

## 🧩 Módulos del Sistema

### 🌱 Alimentos Module

- Gestión de alimentos y recursos nutricionales
- Controlador, servicio y módulo independientes
- Entidad principal: `alimento.entity.ts`

### 🐄 Animales Module

- Administración del inventario animal
- Servicios del dominio ganadero
- Entidad principal: `animal.entity.ts`

### 🔗 Bovino-Alimento Module

- Relación entre animales y alimentación
- Organización de asociaciones del dominio
- Entidad principal: `bovino-alimento.entity.ts`

### 💰 Finanzas Module

- Registro y control financiero
- Controlador, servicio y módulo propios
- Entidad principal: `finanza.entity.ts`

### 🏡 Fincas Module

- Gestión de fincas dentro de la plataforma
- Organización de recursos productivos
- Entidad principal: `finca.entity.ts`

### 🌿 Potreros Module

- Administración de potreros
- Gestión de espacios de producción
- Entidad principal: `potrero.entity.ts`

### ❤️ Salud Module

- Registro de eventos y controles de salud
- Controlador, servicio y módulo dedicados
- Entidad principal: `salud.entity.ts`

### 🔬 Reproducción Module

- Seguimiento de procesos reproductivos
- Organización del módulo con controlador y servicio
- Entidad principal: `reproduccion.entity.ts`

### 👤 Usuarios Module

- Gestión de usuarios del sistema
- Controlador, servicio y módulo asociados
- Entidad principal: `usuario.entity.ts`

---

## 📱 Frontend Móvil y Multiplataforma

El frontend de **FarmLink** está desarrollado con Flutter y organizado para ejecutarse en múltiples plataformas.

Actualmente el proyecto incluye estructura para:

- Android
- iOS
- Web
- Linux
- macOS
- Windows

La carpeta `lib/` concentra la lógica principal de la aplicación mediante componentes reutilizables, pantallas, servicios de consumo de API y configuración visual del sistema.

---

## 🚀 Primeros Pasos

### 🔖 Prerrequisitos

Para trabajar con el proyecto necesitas:

- Git
- Node.js y npm
- Flutter SDK
- Dart SDK
- Un editor como VS Code o Android Studio

---

### 📦 Instalación

Clonar repositorio:

```bash
git clone https://github.com/ISCOUTB/plataforma-ganadera-multitenant.git
cd plataforma-ganadera-multitenant
```

---

### ⚙ Ejecución del Backend

Entrar al backend e instalar dependencias:

```bash
cd Backend
npm install
```

Generar cliente de Prisma:

```bash
npx prisma generate
```

Ejecutar en desarrollo:

```bash
npm run start:dev
```

---

### 📲 Ejecución del Frontend

Entrar al frontend e instalar dependencias:

```bash
cd Frontend
flutter pub get
```

Ejecutar la aplicación:

```bash
flutter run
```

---

## 🎓 Proyecto Académico

Este sistema forma parte de un proyecto académico orientado al desarrollo de una plataforma tecnológica para la gestión ganadera.

Objetivos del proyecto:

- Aplicar arquitectura modular
- Integrar backend y frontend en una sola solución
- Resolver necesidades del contexto productivo ganadero
- Organizar el sistema para evolución futura
- Fortalecer el desarrollo de software aplicado al sector rural

---

## 🎗 Licencia

Este proyecto puede licenciarse bajo la licencia MIT si así lo define el equipo responsable del repositorio.

