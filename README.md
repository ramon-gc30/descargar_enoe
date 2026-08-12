# Descargar los microdatos de la ENOE directamente del repositorio del INEGI
Ramón Carrillo
2028-02-07

# Introducción

Este repositorio consiste en extraer los microdatos de la ENOE
directamente del repositorio del INEGI, es decir, sin la necesidad de
ingresar el enlace.

## Requisitos

``` r
if (require(pacman) == FALSE) {
  install.packages(pacman)
  library(pacman)
} 

pacman::p_load(tidyverse, here, importinegi, foreign, haven, arrow)
source(here::here("scripts", "0_funciones.R"))
```

# Descripción

## Funciones

Las funciones desarrolladas son las siguientes:

```` markdown
```{r}
descargar_enoe(year, trimestre, formato = "csv")
descargar_modulo(year, trimestre, modulo = "sdem", formato = "csv")
```
````

- `descargar_enoe(year, trimestre, formato)`: obtiene los microdatos de
  TODOS los módulos (o tablas) del periodo especificado, devuelve una
  lista donde cada elemento contiene cada módulo de la ENOE o un objeto
  tipo `dataset` de Arrow si se especifico el formato parquet.

- `descargar_modulo(year, trimestre, modulo, formato)`: obtiene los
  microdatos de un módulo y devuelve ya sea un tibble (si se
  especificaron los formatos CSV, STA, SAV), un data frame (en el caso
  de DBF), o bien un `dataset` de Arrow si se especifico el formato
  parquet.

## Argumentos

- `year`: año de levantamiento de la encuesta (2005 a la actualidad),
- `trimestre`: trimestre de levantamiento (1 a 4),
- `formato`: formato del archivo a descargar (CSV, DBF, STA, SAV o
  parquet), por defecto en formato CSV,
- `modulo`: tabla a seleccionar (INEGI, 2023, pp. 1-2):
  - `hog`: hogar,
  - `viv`: vivienda,
  - `sdem`: sociodemográfico (por defecto),
  - `coe1`: cuestionario de ocupación y empleo I,
  - `coe2`: cuestionario de ocupación y empleo II,

# Ejemplos

## Ejemplo 1

Se desea obtener los microdatos correspondientes al tercer trimestre de
2024.

``` r
enoe <- descargar_enoe(2024, 3, "csv")

class(enoe)
```

    [1] "list"

``` r
names(enoe)
```

    [1] "COE1T324" "COE2T324" "HOGT324"  "SDEMT324" "VIVT324" 

Se observa que la función devuelve un objeto tipo lista. Puede definir
cada objeto de forma separada, por ejemplo `sdem <- enoe$SDEMT324`, o
bien puede utilizar `list2env` que crea $n$ objetos en el entorno de
trabajo especificado según el número de objetos contenidos en la lista
`x`. Por ejemplo, se crean los objetos contenidos en `enoe` en el
entorno global.

``` r
list2env(enoe, envir = .GlobalEnv)
```

    <environment: R_GlobalEnv>

``` r
objects(pattern = "T324")
```

    [1] "COE1T324" "COE2T324" "HOGT324"  "SDEMT324" "VIVT324" 

Ahora se puede trabajar con cada conjunto de datos de forma separada.

``` r
SDEMT324
```

    # A tibble: 423,118 × 114
       r_def loc   mun   est   est_d_tri est_d_men ageb  t_loc_tri t_loc_men cd_a 
       <chr> <chr> <chr> <chr> <chr>     <chr>     <chr> <chr>     <chr>     <chr>
     1 0     <NA>  11    20    123       <NA>      0     1         <NA>      1    
     2 0     <NA>  11    20    123       <NA>      0     1         <NA>      1    
     3 0     <NA>  2     30    124       112       0     1         1         1    
     4 0     <NA>  6     30    676       637       0     1         1         1    
     5 0     <NA>  14    40    125       116       0     1         1         1    
     6 0     <NA>  57    30    205       188       0     1         1         1    
     7 0     <NA>  81    20    804       <NA>      0     2         <NA>      1    
     8 0     <NA>  70    20    207       <NA>      0     2         <NA>      1    
     9 0     <NA>  29    20    204       190       0     1         1         1    
    10 0     <NA>  58    30    205       188       0     1         1         1    
    # ℹ 423,108 more rows
    # ℹ 104 more variables: ent <chr>, con <chr>, upm <chr>, d_sem <chr>,
    #   n_pro_viv <chr>, v_sel <chr>, n_hog <chr>, h_mud <chr>, n_ent <chr>,
    #   per <chr>, n_ren <chr>, c_res <chr>, par_c <chr>, sex <chr>, eda <chr>,
    #   nac_dia <chr>, nac_mes <chr>, nac_anio <chr>, l_nac_c <chr>, cs_p12 <chr>,
    #   cs_p13_1 <chr>, cs_p13_2 <chr>, cs_p14_c <chr>, cs_p15 <chr>, cs_p16 <chr>,
    #   cs_p17 <chr>, n_hij <chr>, e_con <chr>, cs_p20a_1 <chr>, cs_p20a_c <chr>, …

Cabe mencionar que el formato CSV devuelve un tibble donde todas las
columnas son de tipo caracter. Se realizo de este modo para evitar
errores al momento de detectar los distintos tipos de columna.

## Ejemplo 2

Se requiere obtener la tabla sociodemográfica de la ENOE correspondiente
al año 2008 del cuarto trimestre en formato parquet.

``` r
sdem <- descargar_modulo(2008, 4, "sdem", "parquet")

sdem
```

    FileSystemDataset with 1 Parquet file
    104 columns
    r_def: string
    loc: string
    mun: string
    est: string
    est_d: string
    ageb: string
    t_loc: string
    cd_a: string
    ent: string
    con: string
    upm: string
    d_sem: string
    n_pro_viv: string
    v_sel: string
    n_hog: string
    h_mud: string
    n_ent: string
    per: string
    n_ren: string
    c_res: string
    ...
    84 more columns
    Use `schema()` to see entire schema

    See $metadata for additional Schema metadata

Cuando se especifica el formato parquet, ambas funciones devuelven un
objeto tipo `datasets` de Arrow, consulte la sección de Actualizaciones
para más información.

## Ejemplo 3

```` markdown
```{r}
descargar_enoe(2020, 2, "csv")
```
````

    Error en descargar_enoe(2020, 2, "csv"): 
      No existe enlace para dicho periodo. Se sugiere utilizar las bases de datos de la ETOE, la cual proporciona información para los meses de abril, mayo y junio: <https://www.inegi.org.mx/investigacion/etoe/default.html#Microdatos>. Las cifras que ofrece ETOE no son estrictamente comparables con ENOE pero son una aproximación a los indicadores de la ENOE. La comparación es útil como medida de referencia.

# Detalles

Existen tres maneras de importar los microdatos de la ENOE

1.  Descargando el archivo en el ordenador y realizar el proceso de
    importación,
2.  Utilizando el paquete `importinegi` (Rentería, 2020),
3.  Descargando el archivo directamente en el repositorio del INEGI

El más sencillo de realizar es la opción 1, aunque dificulta la
reproducibilidad del proyecto.

En cambio el paquete `importinegi` no permite obtener archivos más allá
del año 2022. Por ejemplo, si se desea obtener los microdatos del
segundo trimestre de 2023.

```` markdown
```{r}
# library(importinegi)

importinegi::enoe(2023, "trim2")
```
````

Arrojará el siguiente error

    probando la URL 'https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/enoe_n_2023_trim2_dbf.zip'
    Content type 'text/html' length 2263 bytes
    downloaded 2263 bytes

    simpleWarning in utils::unzip(temp.enoe, exdir = zipdir): error 1 al extraer del archivo zip

    named list()

¿Por qué? Porque volvió a cambiar los enlaces referentes a los
microdatos.

En el repositorio del INEGI, la liga correspondiente a ENOE 2T-2023 es:
<https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/enoe_2023_trim2_dbf.zip>

Mientras que con la función `importinegi::enoe` la liga es:
<https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/enoe_n_2023_trim2_dbf.zip>

Por tanto, tiene que volver a actualizarse dicha función. En específico,

```` markdown
```{r}
if (year >= 2020 & !(year == 2020 & trimestre == 'trim1')) {
    url.base = paste("https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/enoe_n",year,trimestre,paste0(formato,".zip"), sep = "_")
  } else {
    url.base = paste0("http://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/", year, trimestre,  "_", formato, ".zip")
  }
```
````

En ese sentido, la función `descargar_enoe` puede considerarse como una
actualización de `importinegi::enoe` en cuanto a que:

- Actualiza los enlaces hasta la publicación de este documento (finales
  de julio de 2026),
- Evita posibles errores cuando la descarga supera el tiempo máximo
  establecido, \* Permite la descarga de archivos de distinto formato,
- Mejora (al simplificar) la creación del objeto a retornar de la
  función

Para realizar esto último se tomo como fuente el código mostrado por
Wickham y otros (2023, sección 26.3.4).

En cuanto a descargar los microdatos directamente del repositorio del
INEGI, existen aproximaciones previas (Martínez Sánchez, 2017; Pacheco
Castro, 2021).

El código producido por Martínez Sánchez (2017) es el siguiente:

``` {{r}
temporal <- tempfile()
download.file("http://www.beta.inegi.org.mx/contenidos/proyectos/enchogares/regulares/enoe/microdatos/enoe_15ymas/2016/2016trim1_dbf.zip",temporal)
files = unzip(temporal, list=TRUE)$Name
unzip(temporal, files=files[grepl("dbf",files)])
SDEMT116 <- data.frame(read.dbf("sdemt116.dbf"))
```

Donde

1.  Crea un archivo temporal en el directorio temporal,
2.  Descarga el archivo comprimido directamente en el repositorio del
    INEGI y lo almacena en el archivo temporal
3.  Enlista los archivos contenidos dentro del archivo comprimido,
4.  Extrae todos los archivos contenidos
5.  Almacena o guarda en un marco de datos los microdatos
    correspondientes al módulo sociodemográfico.

Por su parte, el código de Pacheco Castro (2021) es:

```` markdown
```{r}
#Descarga de archivos
url<-"https://www.inegi.org.mx/contenidos/programas/enigh/nc/2018/microdatos/enigh2018_ns_viviendas_csv.zip"
##Creación de directorio temporal
td<- tempdir()
# Descarga del archivo temporal
tf = tempfile(tmpdir=td, fileext=".zip")
download.file(url, tf)
# unzip
unzip(tf, files="viviendas.csv", exdir=td, 
      overwrite=TRUE)
fpath=file.path(td,"viviendas.csv")
unlink(td)
```
````

Donde

1.  Almacena el enlace de los microdatos de un periodo determinado (en
    este caso es de la ENIGH),
2.  Guarda la ruta del directorio temporal
3.  Almacena la ruta de un archivo temporal,
4.  Descarga el archivo de la ruta especificada y lo almacena en el
    archivo temporal,
5.  Extrae un archivo específico contenido dentro del archivo
    comprimido,
6.  Elimina los archivos ubicados en el directorio temporal

Cabe mencionar que el código de la función `importinegi::enoe` se parece
a los descritos líneas arriba:

```` markdown
```{r}
enoe = function(year = NA, trimestre = NA, integrar = FALSE){
  if (is.na(year) & is.na(trimestre)) {shell.exec("https://www.inegi.org.mx/programas/enoe/15ymas/")}
  # Temp files
  temp.enoe = tempfile()
  zipdir     = tempdir()
  formato = "dbf"

  # Descargar
  if (year >= 2020 & !(year == 2020 & trimestre == 'trim1')) {
    url.base = paste("https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/enoe_n",year,trimestre,paste0(formato,".zip"), sep = "_")
  } else {
    url.base = paste0("http://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/", year, trimestre,  "_", formato, ".zip")
  }
  utils::download.file(url.base, temp.enoe)
  utils::unzip(temp.enoe, exdir = zipdir)
```
````

En ese sentido, las versiones previas de las funciones descritas
anteriormente (`descargar_enoe` y `descargar_modulo`) requerían el
enlace. Por ejemplo,

```` markdown
```{r}
descargar_modulo(
  url = "https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/enoe_2025_trim1_csv.zip",
  modulo = "sdem"
)
```
````

No obstante, consideramos que las versiones actuales facilitan la
automatización de dicha descarga.

Así pues, el proceso computacional de las funciones desarrolladas en
este espacio es el siguiente:

1.  Se obtiene el enlace según el periodo especificado (año y
    trimestre),
2.  Se descarga el archivo (comprimido) correspondiente,
3.  Se cargan los archivos extraídos según el tipo de formato.

En específico, se generaron dos funciones debido a que a veces es
necesario trabajar solamente con los microdatos de un módulo en
específico. Por ejemplo, para estimar el total de la población ocupada o
para calcular los indicadores del mercado laboral mexicano se requieren
los campos precodificados ubicados solamente en la tabla
sociodemográfica (`SDEM`), véase INEGI (2023) para más información.

# Actualizaciones

29 de julio de 2026

La versión actual de las funciones `descargar_enoe` y `descargar_modulo`
(v4.2) superan las limitaciones presentadas en las versiones previas
donde:

- Ya no es necesario ingresar manualmente el enlace: solamente debe
  especificarse el año y el trimestre de interés,
- Permite descargar todos los formatos disponibles en el repositorio del
  INEGI (además del CSV): DBF, STA, SAV,
- Algunas pruebas realizadas validan su ejecución incluso en periodos
  lejanos al actual

12 de agosto de 2026

Se incorporó el formato parquet como formato de salida en ambas
funciones. Primero descargan el archivo del periodo correspondiente,
después extraen todas las tablas o la tabla especificada, lo carga en R
como tibble (mediante `read_csv`) y posteriormente lo almacena en el
directorio actual de trabajo en la subcarpeta `datos`.

De este modo, ambas devuelven un objeto tipo conjunto de datos
(*datasets*) de Arrow guardando el archivo en la carpeta `datos` dentro
del directorio actual de trabajo. Cabe mencionar que todas las variables
(columnas) son de tipo cadena de texto (`string`). Esto es resultado de
cargar el archivo como tibble con `readr::read_csv`, y no con
`arrow::read_csv_arrow`, especificando dicho tipo de dato en todas las
columnas de la tabla o tablas. Se decidió realizarlo de esta manera para
evitar posibles errores de codificación al momento de ejecutar consultas
desde el conjunto de datos.

Así, podría agilizarse la manipulación de microdatos de la ENOE entre
distintos periodos, véase `aplicacion.md` a modo de ejemplo.

# Referencias

INEGI, \[Instituto Nacional de Estadística y Geografía\]. (2023).
Encuesta Nacional de Ocupación y Empleo. ENOE. Conociendo la base de
datos.
<https://www.inegi.org.mx/rnm/index.php/catalog/1121/related-materials>

Martínez Sánchez, J. C. (2017). Una aproximación metodológica al uso de
datos de encuestas en hogares. Realidad, Datos y Espacio. Revista
Internacional de Estadística y Geografía, 8(2), 52–71.
<https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=702825095352>

Pacheco Castro, C. D. (2021, 15 de julio). Usando R para jugar con los
microdatos del INEGI. tacosdedatos.
<https://medium.com/tacosdedatos/usando-r-para-sacar-informaci%C3%B3n-de-los-microdatos-del-inegi-b21b6946cf4f>

Rentería, C. (2020). importinegi: un paquete de R para descargar y
gestionar bases de datos del INEGI (pp. 140-149). REALIDAD, DATOS Y
ESPACIO REVISTA INTERNACIONAL DE ESTADÍSTICA Y GEOGRAFÍA (Vol. 11, Núm.
3, septiembre-diciembre, 2020).
<https://www.inegi.org.mx/contenidos/productos/prod_serv/contenidos/espanol/bvinegi/productos/nueva_estruc/revista_rde/889463856702.pdf>

Wickham, H.; Cetinkaya-Rundel, M.; y Grolemund, G. (2023). R para la
Ciencia de Datos (2a ed.) \[versión en español, trad. Díaz Rodríguez,
D.\]. <https://davidrsch.github.io/r4ds-es/>
