# Sistema Ganadero Backend

Este proyecto es un sistema de gestión para la administración de un hato ganadero. Permite a los usuarios gestionar información relacionada con la salud, nutrición, reproducción, finanzas y más, facilitando la toma de decisiones informadas para la mejora de la productividad.

## Estructura del Proyecto

El proyecto está organizado en varias carpetas y archivos, cada uno con una función específica:

- **src/**: Contiene el código fuente de la aplicación.
  - **main.py**: Punto de entrada de la aplicación.
  - **app/**: Contiene la lógica de la aplicación, incluyendo controladores, servicios, repositorios, modelos, esquemas, rutas, middlewares y utilidades.
  - **db/**: Contiene las migraciones y seeders para la base de datos.
  - **tests/**: Contiene pruebas unitarias para asegurar la calidad del código.

## Requisitos

Para ejecutar este proyecto, asegúrate de tener instaladas las siguientes dependencias:

- Python 3.x
- Dependencias listadas en `requirements.txt`

## Instalación

1. Clona el repositorio:
   ```
   git clone <URL_DEL_REPOSITORIO>
   cd sistema-ganadero-backend
   ```

2. Crea un entorno virtual y actívalo:
   ```
   python -m venv venv
   source venv/bin/activate  # En Windows usa `venv\Scripts\activate`
   ```

3. Instala las dependencias:
   ```
   pip install -r requirements.txt
   ```

4. Configura las variables de entorno necesarias en un archivo `.env` basado en el archivo `.env.example`.

## Ejecución

Para iniciar la aplicación, ejecuta el siguiente comando:
```
python src/main.py
```

## Contribuciones

Las contribuciones son bienvenidas. Si deseas contribuir, por favor abre un issue o envía un pull request.

## Licencia

Este proyecto está bajo la Licencia [Nombre de la Licencia].