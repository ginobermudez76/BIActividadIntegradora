# Plataforma de Inteligencia de Negocios para la predicción y gestión de brotes de enfermedades vectoriales (Dengue) en el dominio de la salud pública mediante integración de datos heterogéneos

## 1. Abstract (Resumen)

El presente proyecto aborda la ineficiencia en la gestión y prevención de brotes de Dengue en la provincia de Santa Elena (período 2022-2024), problema que satura el sistema hospitalario local debido a una toma de decisiones basada en reportes clínicos aislados y reactivos.

Para resolverlo, se propone implementar un enfoque técnico de Inteligencia de Negocios que centraliza la información mediante un proceso ETL hacia un Data Warehouse estructurado bajo un Modelo Estrella (Star Schema), culminando en un dashboard interactivo desarrollado en Angular.

Se integran siete fuentes de datos heterogéneas que combinan variables epidemiológicas, factores climáticos (Web Scraping meteorológico), disponibilidad farmacéutica e infraestructura médica (Scraping de portales), y percepción ciudadana.

Como resultado, se espera proporcionar a las autoridades sanitarias una herramienta analítica unificada que identifique patrones de riesgo entre el clima y la incidencia de casos, permitiendo anticipar picos de contagio, optimizar la distribución de medicamentos y mejorar la capacidad de respuesta proactiva.

---

## 2. Problema de Negocio

Las autoridades sanitarias y los directores de la red de salud pública en la provincia de Santa Elena sufren de una grave falta de herramientas centralizadas para monitorear y anticipar los brotes de Dengue.

Actualmente, los analistas de salud evalúan los casos confirmados de manera aislada, sin poder cruzar esta información rápidamente con detonantes críticos como las anomalías climáticas (precipitaciones fuertes) o el inventario real en las farmacias de la zona.

Las consecuencias de no resolver esta desconexión de datos incluyen:

- Saturación repentina de las salas de emergencia durante la época invernal.
- Desabastecimiento de insumos paliativos básicos.
- Dificultad para tomar decisiones preventivas que reduzcan las tasas de morbilidad en los cantones afectados.

---

## 3. Pregunta de Investigación Principal

> **¿De qué manera la correlación entre las anomalías climáticas (precipitación y temperatura), la densidad de infraestructura médica y la disponibilidad de insumos farmacéuticos impacta en la tasa de incidencia de casos de Dengue reportados en la provincia de Santa Elena durante el período 2022-2024?**

---

## 4. Preguntas Analíticas Secundarias

1. ¿Cuál es la relación histórica entre los picos de precipitación mensual y el aumento de casos confirmados de Dengue en el mes inmediatamente posterior?

2. ¿Qué zonas o cantones presentan un mayor déficit de infraestructura médica en proporción a su tasa de incidencia de enfermedades vectoriales?

3. ¿Cómo fluctúa la disponibilidad de medicamentos básicos (paracetamol, sueros) en farmacias locales durante las semanas epidemiológicas de mayor nivel de contagio?

---

## 5. Objetivos

### 5.1 Objetivo General

Diseñar una solución integral de Inteligencia de Negocios que integre datos epidemiológicos, climáticos y hospitalarios para identificar patrones de riesgo y optimizar la toma de decisiones preventivas frente a brotes de Dengue.

### 5.2 Objetivos Específicos

1. Integrar datos provenientes de siete fuentes heterogéneas mediante técnicas de Web Scraping, consumo de APIs y lectura de archivos estructurados.

2. Implementar un Data Warehouse centralizado utilizando un modelo analítico Star Schema para relacionar las dimensiones de tiempo, geografía y clima con los hechos de salud.

3. Construir un dashboard funcional utilizando el framework Angular que visualice los KPIs definidos y facilite la generación de insights para las autoridades.

4. Evaluar la calidad de los datos recopilados aplicando métricas de completitud y estandarización durante el proceso de transformación (ETL).

---

## 6. KPIs Preliminares

| KPI / Indicador | Fórmula de cálculo | Fuente esperada | Frecuencia |
|-----------------|--------------------|-----------------|------------|
| **Tasa de incidencia mensual** | (Total casos nuevos en el mes / Población total) × 100000 | Dataset oficial (CSV + API) | Mensual |
| **Índice de riesgo climático** | (Días con lluvia > 10 mm + Días con temperatura > 28 °C) / Total de días del mes | Web Scraping de portales climáticos | Mensual |
| **Disponibilidad farmacéutica** | (Farmacias con stock / Total de farmacias evaluadas) × 100 | Web Scraping de farmacias | Semanal |
| **Cobertura de infraestructura** | Número de centros de salud / (Total de casos reportados / 1000) | Web Scraping de directorios médicos | Semestral |
| **Tasa de síntomas no clínicos** | (Encuestados con fiebre reciente / Total de encuestados) × 100 | Encuesta propia | Quincenal |

---

## 7. Fuentes de Datos

### 7.1 Web Scraping #1 — Clima

Extracción del histórico de precipitaciones y temperaturas desde portales meteorológicos (AccuWeather o INAMHI).

### 7.2 Web Scraping #2 — Noticias y Alertas

Extracción del volumen de noticias relacionadas con el Dengue en diarios locales para medir la percepción social.

### 7.3 Web Scraping #3 — Farmacias

Extracción del inventario de medicamentos (paracetamol, repelentes, etc.) desde cadenas farmacéuticas.

### 7.4 Web Scraping #4 — Infraestructura

Mapeo de directorios médicos para contabilizar centros de salud y dispensarios activos.

### 7.5 API Pública

Consumo de APIs de Datos Abiertos del sector salud o de la OMS para indicadores epidemiológicos.

### 7.6 Archivos Estructurados

Descarga de datasets oficiales en formatos CSV, Excel o JSON con el histórico de enfermedades vectoriales.

### 7.7 Fuente Propia

Formulario desarrollado en Google Forms para recopilar información sobre:

- Síntomas no reportados.
- Tiempos de espera.
- Percepción ciudadana.

---

## 8. Arquitectura Conceptual

### 8.1 Zona RAW

Ingreso de las siete fuentes de datos:

- Python + Scrapy
- APIs públicas
- Archivos CSV
- Exportación de Google Forms

Todos los datos son almacenados inicialmente en un repositorio temporal o bucket de almacenamiento.

### 8.2 Zona STAGING

Procesamiento mediante Python y Pandas para:

- Limpieza de datos.
- Eliminación de duplicados.
- Estandarización de fechas.
- Homologación de nombres de cantones.
- Validación de registros.

### 8.3 Zona Data Warehouse

Base de datos analítica implementada en PostgreSQL utilizando un modelo dimensional Star Schema.

**Tabla de hechos**

- Hechos_Incidencia

**Dimensiones**

- Dim_Tiempo
- Dim_Geografía
- Dim_Clima
- Dim_Infraestructura

### 8.4 Zona Dashboard

Frontend desarrollado en Angular conectado mediante una API REST al Data Warehouse para visualizar en tiempo real:

- KPIs
- Tendencias
- Mapas
- Indicadores
- Alertas

---

## 9. Justificación

El proyecto aborda una problemática crítica en las regiones tropicales y costeras del Ecuador, donde el Dengue genera una elevada carga para el sistema de salud [1].

La integración de tecnologías de Inteligencia de Negocios (Business Intelligence) permite transformar registros aislados en información estratégica para la toma de decisiones [2].

Al centralizar datos climáticos, epidemiológicos y de infraestructura médica dentro de un modelo dimensional [3][4], se proporciona a las autoridades sanitarias una visión integral mediante dashboards interactivos [5].

Esto permite:

- Anticipar brotes.
- Detectar zonas de riesgo.
- Optimizar la distribución de medicamentos.
- Mejorar la planificación de recursos sanitarios.
- Reducir la saturación hospitalaria.

---

## 10. Referencias Bibliográficas

1. Organización Mundial de la Salud (OMS). *Dengue y dengue grave*. Notas descriptivas, 2023. Disponible en: https://www.who.int/es/news-room/fact-sheets/detail/dengue-and-severe-dengue

2. Salhin, M. N. A., Sultan, A. B. M., & Azmi, N. F. M. (2015). *A review of data warehousing in healthcare*. Proceedings of the International Conference on Science in Information Technology (ICSITech), pp. 106–110.

3. Kimball, R., & Ross, M. (2013). *The Data Warehouse Toolkit: The Definitive Guide to Dimensional Modeling* (3rd ed.). Wiley.

4. Inmon, W. H. (2005). *Building the Data Warehouse* (4th ed.). Wiley.

5. Astuti, S. A. G. A., Rosadi, M. I., & Firdaus, M. M. R. (2021). *Business Intelligence Dashboard for Health Care Data Visualizations*. Proceedings of the 6th International Conference on Informatics and Computing (ICIC), pp. 1–6.