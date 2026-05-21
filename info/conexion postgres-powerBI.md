1. Conectar PostgreSQL a Power BI
   Dado que PostgreSQL se está ejecutando localmente en un contenedor de Docker, estos son los pasos para conectarlo desde tu Power BI Desktop:

Abre Power BI Desktop.
En la cinta de opciones principal (Inicio), haz clic en Obtener datos y selecciona Más...
En la ventana que aparece, busca PostgreSQL (puedes usar la barra de búsqueda) y selecciona Base de datos PostgreSQL.
Haz clic en Conectar.
Se te pedirán los detalles de conexión:
Servidor: localhost:5433 (o 127.0.0.1:5433)
Base de datos: northwind
Modo de conectividad de datos: Selecciona Importar (recomendado para modelos estrella para mayor rendimiento).
Haz clic en Aceptar.
Si es la primera vez que te conectas, te pedirá credenciales:
Selecciona la pestaña Base de datos.
Nombre de usuario: postgres
Contraseña: password (esta es la contraseña configurada en el archivo docker-compose.yml).
Haz clic en Conectar.
WARNING

Si Power BI te muestra un error indicando que falta un componente (como Npgsql), deberás descargar e instalar el controlador de .NET para PostgreSQL (Npgsql) desde su sitio web oficial, o deshabilitar el cifrado en la conexión si te pregunta por ello.

2. Seleccionar las tablas del Modelo Estrella
   Una vez establecida la conexión, aparecerá la ventana del Navegador. Aquí verás todas las tablas de la base de datos northwind.

Para el modelo dimensional, SÓLO debes seleccionar las tablas que creamos para el esquema estrella:

fact_sales
dim_customer
dim_product
dim_employee
dim_date
IMPORTANT

No selecciones las tablas originales (como orders, order_details, customers, etc.), ya que eso rompería la estructura del modelo estrella en Power BI.

Haz clic en Cargar.

3. Configurar el Modelo en Power BI
   Una vez cargados los datos, ve a la vista de Modelo (el ícono de relaciones en el lado izquierdo). Power BI intentará autodetectar las relaciones, pero debes verificar que estén correctas:

fact_sales.customer_sk -> dim_customer.customer_sk
fact_sales.product_sk -> dim_product.product_sk
fact_sales.employee_sk -> dim_employee.employee_sk
fact_sales.date_key -> dim_date.date_key
Todas las relaciones deben ser 1 a muchos (1 en la dimensión, \* en la tabla de hechos) y con dirección de filtro único (desde la dimensión hacia los hechos).

4. Construir los KPIs y Dashboard
   Ahora puedes ir a la vista de Informe y empezar a construir tus visualizaciones:

KPI 1: Ventas Totales: Usa la columna sales_amount de fact_sales en una tarjeta.
KPI 2: Cantidad de Pedidos: Cuenta las filas de fact_sales (ya que cada fila es un detalle de pedido, para contar pedidos únicos puedes hacer un DISTINCT COUNT sobre una medida si tuvieras order_id en los hechos, o simplemente contar las transacciones/unidades vendidas usando quantity). Nota: Si quieres la cantidad estricta de "Órdenes", puedes usar SUM(quantity) para el volumen de ítems vendidos.
Evolución Temporal: Usa dim_date.year y dim_date.month_name en el eje X, y sales_amount en el eje Y de un gráfico de líneas.
Ventas por Empleado: Gráfico de barras con dim_employee.employee_name y sales_amount.
Top Clientes: Gráfico de tabla o barras con dim_customer.company_name y sales_amount.
