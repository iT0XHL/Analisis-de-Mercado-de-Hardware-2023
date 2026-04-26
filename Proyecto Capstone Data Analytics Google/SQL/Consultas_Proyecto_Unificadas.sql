-- Limpiando Datos

-- Creando la tabla limpia final para el análisis
CREATE OR REPLACE TABLE `project-061f9b0a-bb73-4860-8c9.ComponentesPC.Componentes_Limpios` AS

WITH DatosProcesados AS (
  SELECT 
    -- 1. Normalización y traducción de columnas al español
    TRIM(product) AS Producto,
    
    -- 2. Conversión de moneda (Euros a Soles a una tasa de 4.05)
    ROUND(price * 4.05, 2) AS Precio_Soles,
    
    -- 3. Estandarización de texto
    INITCAP(TRIM(brand)) AS Marca, 
    TRIM(category) AS Categoria
    
  FROM `project-061f9b0a-bb73-4860-8c9.ComponentesPC.Componentes`
  
  -- 4. Filtro de Outliers (Evitamos precios en 0 o absurdamente altos)
  WHERE price > 0 AND price < 10000 
)

SELECT DISTINCT -- 5. Deduplicación (Elimina cualquier fila exactamente repetida)
  Producto,
  Precio_Soles,
  Marca,
  Categoria,
  
  -- 6. Feature Engineering: Creación de la nueva columna lógica
  CASE 
    WHEN UPPER(Producto) LIKE '%WIFI%' THEN 'Sí'
    ELSE 'No'
  END AS Conectividad_WIFI

FROM DatosProcesados;

SELECT * FROM `project-061f9b0a-bb73-4860-8c9.ComponentesPC.Componentes_Limpios`;

-- Consultas para el Análisis

SELECT 
  Categoria, 
  COUNT(Producto) AS Total_Modelos,
  ROUND(AVG(Precio_Soles), 2) AS Precio_Promedio_Soles
FROM `project-061f9b0a-bb73-4860-8c9.ComponentesPC.Componentes_Limpios`
GROUP BY Categoria
ORDER BY Precio_Promedio_Soles DESC;

SELECT 
  Marca, 
  COUNT(Producto) AS Modelos_Disponibles,
  ROUND(AVG(Precio_Soles), 2) AS Precio_Promedio_Soles
FROM `project-061f9b0a-bb73-4860-8c9.ComponentesPC.Componentes_Limpios`
WHERE Categoria = 'Tarjetas Gráficas'
GROUP BY Marca
ORDER BY Modelos_Disponibles DESC;

SELECT 
  Conectividad_WIFI,
  COUNT(Producto) AS Cantidad_Opciones,
  ROUND(AVG(Precio_Soles), 2) AS Precio_Promedio_Soles
FROM `project-061f9b0a-bb73-4860-8c9.ComponentesPC.Componentes_Limpios`
WHERE Categoria = 'Placas Base'
GROUP BY Conectividad_WIFI;

SELECT 
  Marca,
  COUNT(Producto) AS Cantidad_CPUs,
  ROUND(AVG(Precio_Soles), 2) AS Precio_Promedio,
  MAX(Precio_Soles) AS CPU_Mas_Caro
FROM `project-061f9b0a-bb73-4860-8c9.ComponentesPC.Componentes_Limpios`
WHERE Categoria = 'Procesadores' AND UPPER(Marca) IN ('INTEL', 'AMD')
GROUP BY Marca
ORDER BY Cantidad_CPUs DESC;

SELECT 
  CASE 
    WHEN UPPER(Producto) LIKE '%NVME%' OR UPPER(Producto) LIKE '%M.2%' THEN 'SSD M.2 / NVMe (Alta Velocidad)'
    WHEN UPPER(Producto) LIKE '%SSD%' THEN 'SSD SATA (Velocidad Estándar)'
    WHEN UPPER(Producto) LIKE '%HDD%' OR UPPER(Producto) LIKE '%DISCO DURO%' THEN 'HDD (Mecánico Tradicional)'
    ELSE 'Otro Formato / Externo'
  END AS Tecnologia_Almacenamiento,
  COUNT(Producto) AS Modelos_Disponibles,
  ROUND(AVG(Precio_Soles), 2) AS Precio_Promedio_Soles
FROM `project-061f9b0a-bb73-4860-8c9.ComponentesPC.Componentes_Limpios`
WHERE Categoria = 'Discos Duros'
GROUP BY Tecnologia_Almacenamiento
ORDER BY Precio_Promedio_Soles DESC;

SELECT 
  CASE 
    WHEN UPPER(Producto) LIKE '%DDR4%' THEN 'DDR4 (Estándar / Moderna)'
    WHEN UPPER(Producto) LIKE '%DDR3%' THEN 'DDR3 (Antigua)'
    WHEN UPPER(Producto) LIKE '%DDR2%' THEN 'DDR2 (Legacy / Reparación)'
    ELSE 'Otra / No especificada'
  END AS Generacion_RAM,
  COUNT(Producto) AS Total_Modelos,
  ROUND(AVG(Precio_Soles), 2) AS Precio_Promedio_Soles
FROM `project-061f9b0a-bb73-4860-8c9.ComponentesPC.Componentes_Limpios`
WHERE Categoria = 'Memorias RAM'
GROUP BY Generacion_RAM
ORDER BY Total_Modelos DESC; -- Ordenado por las que más se venden