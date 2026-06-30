# Arquitectura de Datos Técnica

La solución propuesta se estructura en un **pipeline de datos de cuatro capas principales**, diseñado para extraer, transformar, almacenar y visualizar la información de manera eficiente.

---

## 1. Arquitectura de Datos Técnica

### 1.1 Orígenes de Datos

#### Mecanismos de extracción

- **Web Scraping** mediante Python utilizando librerías como **Scrapy** y **BeautifulSoup** para obtener:
  - Datos meteorológicos.
  - Inventario de farmacias.
  - Directorios hospitalarios.
  - Noticias locales.

- **Consumo de APIs REST** para obtener información de:
  - Organización Mundial de la Salud (OMS).
  - Ministerio de Salud Pública.

- **Carga automatizada de archivos** provenientes de:
  - CSV oficiales.
  - Excel.
  - JSON.
  - Exportaciones de Google Forms.

---

### 1.2 Interconexión

#### Scripts de procesamiento

Los procesos ETL serán desarrollados en **Python**.

Se emplearán las siguientes librerías:

| Librería | Propósito |
|----------|-----------|
| Pandas | Limpieza, transformación y análisis de datos en memoria |
| SQLAlchemy | Conexión e inserción de datos hacia PostgreSQL |
| psycopg2 | Ejecución de consultas SQL e integración con PostgreSQL |

---

### 1.3 Zonas del Data Warehouse

#### Zona RAW

Almacenamiento temporal donde aterrizan los datos originales sin modificaciones.

**Formatos recibidos**

- JSON
- CSV
- HTML
- Excel

---

#### Zona STAGING

Espacio temporal de procesamiento utilizando DataFrames de Pandas.

**Procesos realizados**

- Limpieza de datos.
- Manejo de valores nulos.
- Homologación de nombres de cantones.
- Conversión de tipos de datos.
- Estandarización de formatos.

Ejemplos de homologación:

- La Libertad
- Santa Elena
- Salinas

---

#### Zona Data Warehouse

Base de datos analítica implementada en **PostgreSQL**, estructurada bajo un **Modelo Estrella (Star Schema)**.

---

### 1.4 Capa de Business Intelligence

El sistema contará con un **Dashboard Web** desarrollado en **Angular**.

El frontend consumirá los datos mediante una **API REST**, permitiendo visualizar indicadores, tendencias y análisis provenientes del Data Warehouse.

---

# 2. Modelo Dimensional

## 2.1 Declaración de Granularidad

> Cada fila dentro de la tabla de hechos representará el registro semanal consolidado de incidencia de casos de Dengue, junto con las métricas promedio de factores climáticos y saturación de servicios médicos, asociado a un identificador de tiempo (semana epidemiológica) y un identificador geográfico (cantón).

---

## 2.2 Matriz del Modelo de Hechos

### Tabla: `Fact_Incidencia`

| Campo | Tipo SQL | Descripción funcional | Rol estructural |
|--------|----------|----------------------|-----------------|
| id_hecho | INT | Clave primaria surrogada autoincremental | PK |
| id_tiempo | INT | Clave hacia la dimensión de tiempo | FK |
| id_geografia | INT | Clave hacia la dimensión geográfica | FK |
| id_clima | INT | Clave hacia la dimensión climática | FK |
| id_infraestructura | INT | Clave hacia la dimensión de infraestructura médica | FK |
| casos_confirmados | INT | Total de contagios nuevos | Métrica |
| alertas_mediaticas | INT | Cantidad de noticias relacionadas con riesgo epidemiológico | Métrica |
| pct_stock_meds | DECIMAL(5,2) | Porcentaje de farmacias abastecidas | Métrica |
| espera_promedio_h | DECIMAL(4,2) | Tiempo promedio de atención hospitalaria (horas) | Métrica |

---

# 3. Justificación de la Topología del Esquema

## 3.1 Comparación de alternativas

| Criterio | Star Schema | Snowflake | Galaxy Schema |
|----------|------------|-----------|---------------|
| Rendimiento en consultas | Alto | Medio | Alto |
| Redundancia | Alta | Baja | Media |
| Complejidad | Baja | Media | Alta |
| ¿Aplica al proyecto? | ✅ Sí | ❌ No | ❌ No |

---

## 3.2 Justificación

Se selecciona el **Modelo Estrella (Star Schema)** debido a que el proyecto posee un único proceso de negocio central: el monitoreo de la incidencia del Dengue.

Una tabla de hechos central acompañada de dimensiones desnormalizadas ofrece:

- Alto rendimiento en consultas.
- Menor número de JOINs.
- Baja complejidad.
- Excelente desempeño para dashboards analíticos.

Esta estructura permite que la aplicación desarrollada en Angular pueda consultar los KPIs prácticamente en tiempo real desde PostgreSQL, evitando la sobre-normalización característica del modelo Snowflake.

---

# 4. Diccionario de Datos

## 4.1 Tabla de Hechos

### Fact_Incidencia

| Campo DW | Tipo | Regla / Valores | Atributo Staging | Transformación | Fuente |
|-----------|------|----------------|------------------|----------------|--------|
| casos_confirmados | INT | >= 0 | stg_nuevos_casos | Suma agrupada por cantón y semana epidemiológica | CSV Oficial |
| pct_stock_meds | DECIMAL | 0–100 | stg_disp_farmacias | Promedio ponderado de farmacias con stock | Scraping Farmacias |
| espera_promedio_h | DECIMAL | > 0 | stg_horas_espera | Media aritmética de encuestas | Formularios propios |

---

## 4.2 Dimensión Tiempo

### Dim_Tiempo

| Campo DW | Tipo | Regla | Atributo Staging | Transformación | Fuente |
|-----------|------|--------|------------------|----------------|--------|
| id_tiempo | INT | Formato YYYYMMDD | stg_fecha_registro | Conversión y cast a entero | Todas |
| semana_epidem | INT | 1–52 | stg_fecha_registro | `isocalendar().week` de Pandas | Todas |

---

## 4.3 Dimensión Geografía

### Dim_Geografia

| Campo DW | Tipo | Regla | Atributo Staging | Transformación | Fuente |
|-----------|------|--------|------------------|----------------|--------|
| canton | VARCHAR | Catálogo oficial de cantones | stg_ciudad_texto | Homologación (Upper Case) y mapeo de sinónimos | Scraping / API / CSV |

---

## 4.4 Dimensión Clima

### Dim_Clima

| Campo DW | Tipo | Regla | Atributo Staging | Transformación | Fuente |
|-----------|------|--------|------------------|----------------|--------|
| precipitacion_mm | DECIMAL | >= 0 | stg_lluvia_bruta | Eliminación del sufijo "mm" y conversión a Float | Scraping Clima |
| temp_maxima_c | DECIMAL | — | stg_temp_raw | Extracción del valor numérico y conversión a °C | Scraping Clima |

---

## 4.5 Dimensión Infraestructura

### Dim_Infraestructura

| Campo DW | Tipo | Regla | Atributo Staging | Transformación | Fuente |
|-----------|------|--------|------------------|----------------|--------|
| nivel_saturacion | VARCHAR | Bajo / Medio / Alto | stg_camas_disp | Regla IF/ELSE basada en ocupación (>85% = Alto) | Scraping / API |
| centros_activos | INT | >= 0 | stg_dir_medicos | Conteo distinto (`COUNT()`) de centros de salud activos | Directorios médicos |

---

# 5. Trazabilidad (Mapeo ETL)

La trazabilidad del proceso ETL se resume en el siguiente flujo:

```text
Fuentes de Datos
        │
        ▼
 Zona RAW
(JSON • CSV • HTML • Excel)
        │
        ▼
 Zona STAGING
(Pandas)
        │
        ├── Limpieza
        ├── Homologación
        ├── Conversión de tipos
        ├── Agregaciones
        └── Validaciones
        │
        ▼
Data Warehouse
(PostgreSQL - Star Schema)
        │
        ▼
API REST
        │
        ▼
Dashboard Angular
```