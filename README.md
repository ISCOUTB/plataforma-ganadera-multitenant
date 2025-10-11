[<img src="https://img.icons8.com/?size=512&id=55494&format=png" align="right" width="25%" padding-right="350">]()

# `PLATAFORMA-GANADERA-MULTITENANT`

#### <code>❯ Sistema integral de gestión ganadera</code>

<p align="left">
	<img src="https://img.shields.io/github/license/ISCOUTB/plataforma-ganadera-multitenant?style=social&logo=opensourceinitiative&logoColor=white&color=00ff1b" alt="license">
	<img src="https://img.shields.io/github/last-commit/ISCOUTB/plataforma-ganadera-multitenant?style=social&logo=git&logoColor=white&color=00ff1b" alt="last-commit">
	<img src="https://img.shields.io/github/languages/top/ISCOUTB/plataforma-ganadera-multitenant?style=social&color=00ff1b" alt="repo-top-language">
	<img src="https://img.shields.io/github/languages/count/ISCOUTB/plataforma-ganadera-multitenant?style=social&color=00ff1b" alt="repo-language-count">
</p>

<p align="left">
	<em>Construido con las siguientes tecnologías:</em>
</p>
<p align="center">
	<img src="https://img.shields.io/badge/Python-3776AB.svg?style=social&logo=Python&logoColor=white" alt="Python">
	<img src="https://img.shields.io/badge/Flask-000000.svg?style=social&logo=Flask&logoColor=white" alt="Flask">
	<img src="https://img.shields.io/badge/HTML5-E34F26.svg?style=social&logo=HTML5&logoColor=white" alt="HTML5">
	<img src="https://img.shields.io/badge/CSS3-1572B6.svg?style=social&logo=CSS3&logoColor=white" alt="CSS3">
	<img src="https://img.shields.io/badge/JavaScript-F7DF1E.svg?style=social&logo=JavaScript&logoColor=white" alt="JavaScript">
	<img src="https://img.shields.io/badge/Docker-2496ED.svg?style=social&logo=Docker&logoColor=white" alt="Docker">
	<img src="https://img.shields.io/badge/GitHub%20Actions-2088FF.svg?style=social&logo=GitHub-Actions&logoColor=white" alt="GitHub%20Actions">
</p>

<br>

##### 🔗 Tabla de contenidos

- [📍 Descripción General](#-DescripciónGeneral)
- [👾 Características](#-Características)
- [📂 Estructura del Repositorio](#-EstructuradelRepositorio)
- [🧩 Módulos](#-Módulos)
- [🚀 Primeros Pasos](#-PrimerosPasos)
    - [🔖 Prerequisitos](#-Prerequisitos)
    - [📦 Instalación](#-Instalación)
    - [🤖 Uso](#-Uso)
    - [🧪 Pruebas](#-Pruebas)
- [🎗 Licencia](#-Licencia)

---

## 📍 DescripciónGeneral

**Plataforma Ganadera Multitenant** es un sistema web diseñado para la administración integral de operaciones ganaderas.  
Permite gestionar múltiples fincas dentro de un mismo entorno, optimizando la producción, distribución y control de recursos.

Su arquitectura **multitenant** facilita la separación de datos y la personalización por usuario o finca, brindando escalabilidad y seguridad a gran escala.

---

## 👾 Características

- 🐄 **Gestión de animales:** Registro, seguimiento y control sanitario de ganado.
- 🌾 **Gestión de fincas:** Control independiente de múltiples fincas bajo una misma cuenta.
- 💰 **Monitoreo de costos:** Análisis detallado de costos de producción y alimentación.
- ⚙️ **Mantenimiento de equipos:** Solicitud, seguimiento y registro de mantenimientos.
- 🚚 **Gestión de distribución:** Control de envíos, entregas y rutas de distribución.
- 🧾 **Gestión de inventario:** Control de insumos, productos y materiales.
- ☁️ **Arquitectura multitenant:** Separación de datos por finca o cliente.
- 📊 **Reportes y dashboards:** Visualización en tiempo real de indicadores clave.
- 🔐 **Gestión de roles:** Permite definir roles de administrador, granjero y cliente.
- 🌎 **Integración con APIs externas:** Soporte para servicios meteorológicos, pagos o logística.

---

## 📂 EstructuradelRepositorio

```sh
└── plataforma-ganadera-multitenant/
    ├── app/
    │   ├── __init__.py
    │   ├── main.py
    │   ├── routes/
    │   ├── models/
    │   ├── templates/
    │   └── static/
    ├── config/
    │   └── settings.py
    ├── docker-compose.yml
    ├── Dockerfile
    ├── requirements.txt
    ├── .env
    ├── .gitignore
    └── README.md
```

---

## 🧩 Módulos

<details closed><summary>Administrador</summary>

| Función | Descripción |
| --- | --- |
| Actualizar configuración del sistema | Permite cambiar ajustes globales. |
| Resolver disputas | Gestiona conflictos entre usuarios o fincas. |
| Monitorear rendimiento | Supervisa métricas clave del sistema. |
| Asignar roles | Controla permisos de usuario. |
| Generar reportes | Produce informes de desempeño y productividad. |

</details>

<details closed><summary>Granjero</summary>

| Función | Descripción |
| --- | --- |
| Monitorear costos de producción | Control de gastos de alimentación y mantenimiento. |
| Gestionar proveedores | Registro y administración de proveedores de insumos. |
| Registrar uso de maquinaria | Control del uso y disponibilidad de equipos. |
| Control de calidad | Evaluación de productos ganaderos. |
| Gestión de inventario | Control de existencias de productos e insumos. |
| Distribución y ventas | Registro y control de distribución de productos. |
| Solicitar mantenimiento | Petición de reparaciones o revisiones técnicas. |
| Monitoreo de suelo y clima | Pronósticos e información ambiental en tiempo real. |

</details>

<details closed><summary>Cliente</summary>

| Función | Descripción |
| --- | --- |
| Lista de deseos | Guarda productos o servicios favoritos. |
| Exploración de categorías | Navegación por productos ganaderos. |
| Rastrear entregas | Seguimiento de pedidos y envíos. |
| Solicitar reembolsos o cambios | Gestión de devoluciones y reclamos. |
| Dejar reseñas | Opiniones sobre productos y servicios. |

</details>

---

## 🚀 PrimerosPasos

### 🔖 Prerequisitos

- **Python**: `3.9` o superior  
- **Docker** (opcional, para despliegue rápido)  
- **pip** o **pipenv** para la instalación de dependencias  

---

### 📦 Instalación

1. Clonar el repositorio:
```bash
git clone https://github.com/ISCOUTB/plataforma-ganadera-multitenant.git
```

2. Entrar en el directorio:
```bash
cd plataforma-ganadera-multitenant
```

3. Instalar las dependencias:
```bash
pip install -r requirements.txt
```

---

### 🤖 Uso

Para ejecutar la aplicación localmente:
```bash
python app/main.py
```

O con Docker:
```bash
docker-compose up --build
```

---

### 🧪 Pruebas

Ejecutar el conjunto de pruebas:
```bash
pytest
```

---

## 🎗 Licencia

Este proyecto está protegido bajo la licencia [MIT License](https://choosealicense.com/licenses/mit/).  
Consulta el archivo [LICENSE](./LICENSE) para más detalles.

---
