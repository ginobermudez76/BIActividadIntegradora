# Instrucciones para la Configuración de la Base de Datos Northwind BI

Este documento detalla los pasos para crear la base de datos `northwind`, cargar los datos transaccionales, y generar el modelo estrella tanto de forma **manual** (sin Docker) como de forma **automatizada** (con Docker).

---

## Opción 1: Configuración Manual (Sin Docker)

Si prefieres no utilizar Docker o tienes tu propia instalación local de PostgreSQL (por ejemplo, a través de pgAdmin), sigue estos pasos:

### 1. Preparar el servidor
- Asegúrate de tener instalado PostgreSQL en tu equipo (versión 12 o superior recomendada).
- Abre tu cliente preferido de PostgreSQL (pgAdmin, DBeaver, o `psql` desde la consola) y conéctate a tu servidor local.

### 2. Crear la base de datos
- Crea una nueva base de datos llamada `northwind`.
  ```sql
  CREATE DATABASE northwind;
  ```
- Conéctate a la recién creada base de datos `northwind`.

### 3. Ejecutar los scripts en orden
Deberás ejecutar los siguientes archivos `.sql` (ubicados en la carpeta `sql/` de este proyecto) **exactamente en este orden**:

1. **`northwind.sql`**: 
   - Ejecuta este archivo completo. Esto creará todas las tablas transaccionales originales (orders, products, customers, etc.) y las poblará con la información base.
2. **`01_star_schema.sql`**:
   - Ejecuta este script. Se encargarán de crear las tablas de nuestro modelo dimensional (las dimensiones `dim_customer`, `dim_product`, `dim_date`, `dim_employee` y la tabla de hechos `fact_sales`).
3. **`02_migration.sql`**:
   - Ejecuta este script final. Contiene las sentencias `INSERT INTO ... SELECT ...` que extraen los datos de las tablas originales y los transforman para insertarlos en tu nuevo modelo estrella.

¡Listo! Ya tienes la base de datos lista para ser conectada a Power BI (normalmente en el puerto `5432`).

---

## Opción 2: Configuración Automatizada (Con Docker)

Si prefieres una solución rápida y encapsulada que no interfiera con tu sistema local, puedes usar Docker. Todo el proceso de creación y migración está automatizado.

### 1. Requisitos previos
- Debes tener instalados **Docker** y **Docker Compose** (o Docker Desktop) en tu máquina.

### 2. Levantar el contenedor
- Abre una terminal (Símbolo del sistema, PowerShell o la terminal de tu editor) y navega hasta la carpeta raíz del proyecto (donde se encuentra el archivo `docker-compose.yml`).
- Ejecuta el siguiente comando:
  ```bash
  docker compose up -d
  ```

### 3. ¿Qué sucede internamente?
- Docker descargará la imagen de PostgreSQL 15.
- Levantará un contenedor llamado `northwind_bi_db`.
- **Ejecución Automática**: Como los archivos `.sql` están mapeados en la carpeta de inicialización (`/docker-entrypoint-initdb.d/`), PostgreSQL los ejecutará automáticamente en orden alfabético al crear la base de datos por primera vez.
- La base de datos y el modelo estrella quedarán listos sin que tengas que ejecutar ningún script manualmente.

### 4. Datos de conexión
Una vez que el comando finalice y el contenedor esté corriendo, podrás conectar Power BI usando estos datos:
- **Servidor**: `localhost:5433` *(Nota: Usamos el puerto 5433 para evitar conflictos con otras instalaciones locales).*
- **Base de datos**: `northwind`
- **Usuario**: `postgres`
- **Contraseña**: `password`
