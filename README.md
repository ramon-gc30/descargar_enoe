# Descargar los microdatos de la ENOE directamente del repositorio del INEGI
Ramón Carrillo
2028-02-07

## Introducción

Este repositorio pretende generar el código fuente que permita descargar
los microdatos de la ENOE directamente del repositorio del INEGI.

``` r
if (require(pacman) == FALSE) {
  install.packages(pacman)
  library(pacman)
} 

pacman::p_load(tidyverse, here, importinegi)
source(here::here("scripts", "0_funciones.R"))
```

## Modos de obtener microdatos de la ENOE en R

Existen tres maneras de importar los microdatos de la ENOE

1.  Descargando el archivo en el ordenador y realizar el proceso de
    importación,
2.  Utilizando el paquete `importinegi` (Rentería, 2020),
3.  Descargando el archivo directamente en el repositorio del INEGI

El más sencillo de realizar es la opción 1, anque dificulta la
reproducibilidad del proyecto.

En cambio el paquete `importinegi` no permite obtener archivos más allá
del año 2022. Por ejemplo, se desea obtener los microdatos del segundo
trimestre de 2023.

``` r
# library(importinegi)

importinegi::enoe(2023, "trim2")
```

    Warning in utils::unzip(temp.enoe, exdir = zipdir): error 1 al extraer del
    archivo zip

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

Solamente que aquí, como se mencionó anteriormente, ya viene incorporado
el enlace (con las respectivas desventajas que conlleva como, entre
otros, que arroje error si el instituto cambia la sintaxsis del enlace).

## Funciones desarrolladas

En ese sentido, las funciones desarrolladas en este espacio tampoco se
alejan de la idea principal de estas aproximaciones en cuanto a que
primero se crean los archivos temporales, posteriormente se descargar y
por último se extraen.

No obstante, pretendemos desglosar este proceso de obtención en dos
funciones:

1.  Obtiene todos los microdatos de la ENOE, es decir, de todos los
    módulos o cuestionarios
2.  Descargar los microdatos de un módulo en específico

Se realiza de esta manera debido a que a veces es necesario trabajar
solamente con los microdatos de un módulo. Por ejemplo, al estimar el
total de la población o calcular los indicadores del mercado laboral
mexicano. Aquello posible con los campos precodificados ubicados
principalmente en el módulo sociodemográfico, véase INEGI (2023) para
más información.

Así pues, las funciones desarrolladas son las siguientes:

```` markdown
```{r}
# library(tidyverse)
descargar_enoe(url)
descargar_microdatos_enoe(url, cuestionario)
```
````

- `descargar_enoe(url)`: obtiene los microdatos de TODOS los módulos
  donde `url` debe contener el enlace de los microdatos en formato CSV y
  devuelve una lista donde cada elemento contiene cada módulo de la ENOE
  en formato tibble.

- `descargar_microdatos_enoe(url, cuestionario)`: obtiene los microdatos
  de un módulo donde en `cuestionario` se especifica el módulo de
  interés. Actualmente acepta los siguiente valores:

  - `hog`: hogar,
  - `viv`: vivienda,
  - `sdem`: sociodemográfico,
  - `coe1` y `coe2`: cuestionario de ocupación y empleo I y II,
    respectivamente

Esta función devuelve un objeto tipo tibble del módulo correspondiente.

En ambos casos, el proceso es el siguiente

1.  Almacenar la ruta del directorio y archivo temporal
2.  Descargar el archivo comprimido directamente en el repositorio del
    INEGI y guardarlo en el archivo temporal
3.  Extraer el o los archivos contenidos en el archivo comprimido
4.  Definir los datos como datos ordenados (tibbles)
5.  Eliminar los archivos descargados y extraídos

De los casos descritos anteriormente, en este código se añade una opción
que aumenta el tiempo máximo de descarga de 1 minuto (por defecto) a 15
minutos mediante la función `options` ya que a veces puede arrojar error
si el archivo no se descarga en el tiempo establecido por defecto.

Además, los microdatos están en objetos tipo tibble que facilita la
manipulación de datos. Por lo cual, requiere el paquete `tidyverse`
(Wickham et. al., 2019)

Por ejemplo, se desea obtener los microdatos de todos los módulos
correspondientes al segundo trimestre de 2025:

``` r
url <- "https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/enoe_2025_trim2_csv.zip"

enoe <- descargar_enoe(url)
names(enoe)
```

    [1] "coe1" "coe2" "hog"  "sdem" "viv" 

Para manipular cada módulo simplemente se define. Por ejemplo, se desea
trabajar con los datos del cuestionario sociodemográfico

``` r
sdem <- enoe$sdem

nrow(sdem)
```

    [1] 423744

``` r
ncol(sdem)
```

    [1] 114

Limitantes

1.  El tiempo de ejecución es relativamente elevado

``` r
system.time(descargar_enoe(url))
```

       user  system elapsed 
      39.66    6.52   57.65 

2.  Necesita especificarse el enlace

3.  Devuelve una lista y no distintos tibbles

Por su parte, se desea el módulo SDEM del mismo periodo (ENOE 2T-2025).
Aquello se realiza con la función `descargar_microdatos_enoe`

``` r
# cuestionario <- "sdem"

sdem2 <- descargar_microdatos_enoe(url, cuestionario = "sdem")

nrow(sdem2)
```

    [1] 423744

``` r
ncol(sdem2)
```

    [1] 114

Limitantes

1.  Tiempo de ejecución relativamente elevado

``` r
system.time(descargar_microdatos_enoe(url, cuestionario = "sdem"))
```

       user  system elapsed 
      13.37    1.78   28.42 

2.  Solo considera archivos CSV, no DBF u otros.

La limitación general de ambas funciones es que han sido probadas con
los enlaces de los microdatos de la ENOE de los años 2025 y 2026. Se
desconoce si se ejecuta correctamente en periodos previos.

Futuras ampliaciones

- Considerar formatos adicionales como DBF
- Probar la ejecución de ambas funciones en periodos previos a 2025

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

Wickham, H., Averick, M., Bryan, J., Chang, W., McGowan, L., François,
R., Grolemund, G., Hayes, A., Henry, L., Hester, J., Kuhn, M., Pedersen,
T., Miller, E., Bache, S., Müller, K., Ooms, J., Robinson, D., Seidel,
D., Spinu, V., … Yutani, H. (2019). Welcome to the Tidyverse. Journal of
Open Source Software, 4(43), 1686. <https://doi.org/10.21105/joss.01686>
