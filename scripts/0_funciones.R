# Obtener todos los módulos sin enlace ========================================
# arregla la función `importinegi::enoe`

descargar_enoe <- function(year, trimestre, formato = "csv")
{
  # para formato parquet se requiere csv
  if (formato != "parquet") {
    parquet <- 0
  } else {
    formato <- "csv"
    parquet <- 1
  }
  
  url <- "https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/"
  
  # obtener enlaces según el periodo
  if (year >= 2023) {
    url <- paste(url, "enoe_", year, "_trim", trimestre, "_", formato, ".zip", sep = "")
  } else if ((year == 2020 & trimestre >= 3 ) | (year >= 2021 & year <= 2022)) {
    url <- paste(url, "enoe_n_", year, "_trim", trimestre, "_", formato, ".zip", sep = "")
  } else {
    url <- paste(url, year, "trim", trimestre, "_", formato, ".zip", sep = "")
  }
  
  # enlaces con casos especiales
  # doble barra
  if (year == 2024 & trimestre == 2) {
    url <- sub(
      x = url,
      pattern = "/enoe_2024",
      replacement = "//enoe_2024"
    )
  } else if (year == 2020 & trimestre == 2) {
    # no existe enlace
    stop("No existe enlace para dicho periodo. Se sugiere utilizar las bases de datos de la ETOE, la cual proporciona información para los meses de abril, mayo y junio: <https://www.inegi.org.mx/investigacion/etoe/default.html#Microdatos>. Las cifras que ofrece ETOE no son estrictamente comparables con ENOE pero son una aproximación a los indicadores de la ENOE. La comparación es útil como medida de referencia.")
  }
  
  # proceso de descarga
  archivo_temp <- tempfile(fileext = ".zip")
  
  # se aumenta tiempo máximo de descarga para evitar error
  options(timeout = max(900, getOption("timeout")))
  
  download.file(
    url = url,
    destfile = archivo_temp
  )
  
  # extracción
  unzip(
    zipfile = archivo_temp,
    exdir = tempdir()
  )
  
  # ruta para cargar archivos
  archivo_temp <- list.files(
    path = tempdir(),
    pattern = "\\.csv$|\\.dbf$|\\.dta$|\\.sav$",
    full.names = TRUE,
    ignore.case = TRUE
  )
  
  # nombre para la lista
  nombres <- basename(archivo_temp)
  
  nombres <- sub(
    x = nombres,
    pattern = "ENOE_|ENOEN_",
    replacement = ""
  )
  
  nombres <- sub(
    x = nombres,
    pattern = "\\.csv|\\.dbf|\\.dta|\\.sav",
    replacement = "",
    ignore.case = TRUE
  )
  
  # especificar formato para importación
  if (formato == "csv") {
    importar_archivo <- \(archivo_temp)
    readr::read_csv(
      file = archivo_temp,
      col_types = cols(.default = col_character())
    )
  } else if (formato == "dbf") {
    importar_archivo <- foreign::read.dbf
  } else if (formato == "dta") {
    importar_archivo <- haven::read_dta
  } else if (formato == "sav") {
    importar_archivo <- haven::read_sav
  }
  
  # La IA sugiere validar formato con una lista
  # importar_archivo <- list(
  #   csv = \(x) readr::read_csv(file = x, col_types = readr::cols(.default = readr::col_character())),
  #   dbf = foreign::read.dbf,
  #   dta = haven::read_dta,
  #   sav = haven::read_sav
  # )
  # 
  # importar_archivo <- importar_archivo[[formato]]
  
  # importación a un solo objeto tipo lista
  # fuente R for Data Science (2nd ed.), sección 26.3.4
  enoe <- archivo_temp |> 
    purrr::set_names(nm = nombres) |> 
    purrr::map(importar_archivo)
  
  # con formato parquet se exportan archivos
  if (parquet == 1) {
    # archivos de salida
    archivo_parquet <- basename(archivo_temp)
    archivo_parquet <- sub("csv", "parquet", archivo_parquet)
    directorio <- file.path(getwd(), "ENOE")
    
    if (dir.exists(directorio) == FALSE) { dir.create(directorio) }
    
    archivo_parquet <- file.path(directorio, archivo_parquet)
    
    # exportación 
    tamanio <- length(archivo_parquet)
    i <- vector("integer", tamanio)
    
    for (i in 1:tamanio) {
      write_parquet(
        x = enoe[[i]],
        sink = grepv(nombres[[i]], archivo_parquet, ignore.case = TRUE)
      )
    }
    
    # carga
    enoe <- open_dataset(archivo_parquet)
  }
  
  # eliminación de archivos descargados y extraídos
  archivo_temp <- list.files(
    path = tempdir(),
    pattern = "\\.zip$|\\.csv$|\\.dbf$|\\.dta$|\\.sav$",
    full.names = TRUE,
    ignore.case = TRUE
  )
  
  unlink(archivo_temp)
  
  return(enoe)
}

# Obtener un módulo sin enlace ================================================

descargar_modulo <- function(year, trimestre, modulo = "sdem", formato = "csv")
{
  # formato parquet requiere csv
  if (formato != "parquet") {
    parquet <- 0
  } else {
    formato <- "csv"
    parquet <- 1
  }
  
  url <- "https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/"
  
  # obtener enlaces según el periodo
  if (year >= 2023) {
    url <- paste(url, "enoe_", year, "_trim", trimestre, "_", formato, ".zip", sep = "")
  } else if ((year == 2020 & trimestre >= 3 ) | (year >= 2021 & year <= 2022)) {
    url <- paste(url, "enoe_n_", year, "_trim", trimestre, "_", formato, ".zip", sep = "")
  } else {
    url <- paste(url, year, "trim", trimestre, "_", formato, ".zip", sep = "")
  }
  
  # enlaces con casos especiales
  # doble barra
  if (year == 2024 & trimestre == 2) {
    url <- sub(
      x = url,
      pattern = "/enoe_2024",
      replacement = "//enoe_2024"
    )
  } else if (year == 2020 & trimestre == 2) {
    # no existe enlace
    stop("No existe enlace para dicho periodo. Se sugiere utilizar las bases de datos de la ETOE, la cual proporciona información para los meses de abril, mayo y junio: <https://www.inegi.org.mx/investigacion/etoe/default.html#Microdatos>. Las cifras que ofrece ETOE no son estrictamente comparables con ENOE pero son una aproximación a los indicadores de la ENOE. La comparación es útil como medida de referencia.")
  }
  
  # proceso de descarga
  archivo_temp <- tempfile(fileext = ".zip")
  
  # se aumenta tiempo máximo de descarga para evitar error
  options(timeout = max(900, getOption("timeout")))
  
  download.file(
    url = url,
    destfile = archivo_temp
  )
  
  # lista de los microdatos comprimidos
  microdatos <- unzip(archivo_temp, list = TRUE)$Name
  
  # extracción
  unzip(
    zipfile = archivo_temp, 
    # modulo especifico
    files = grepv(modulo, microdatos, ignore.case = TRUE),
    exdir = tempdir()
  )
  
  # ruta para cargar archivos
  archivo_temp <- list.files(
    path = tempdir(),
    pattern = "\\.csv$|\\.dbf$|\\.dta$|\\.sav$",
    full.names = TRUE,
    ignore.case = TRUE
  )
  
  # importación según tipo de archivo
  if (formato == "csv") {
    enoe <- readr::read_csv(
      file = archivo_temp,
      col_types = cols(.default = col_character())
    )
  } else if (formato == "dbf") {
    enoe <- foreign::read.dbf(archivo_temp)
  } else if (formato == "dta") {
    enoe <- haven::read_dta(archivo_temp)
  } else if (formato == "sav") {
    enoe <- haven::read_sav(archivo_temp)
  }
  
  # en formato parquet se exportan archivos 
  if (parquet == 1) {
    # archivos de salida
    archivo_parquet <- basename(archivo_temp)
    archivo_parquet <- sub("csv", "parquet", archivo_parquet)
    directorio <- file.path(getwd(), "ENOE")
    
    if (dir.exists(directorio) == FALSE) { dir.create(directorio) } 
    
    archivo_parquet <- file.path(directorio, archivo_parquet)
    
    # guardar/exportar
    write_parquet(
      x = enoe,
      sink = archivo_parquet
    )
    
    # carga como conjunto de datos
    enoe <- open_dataset(archivo_parquet)
  }
  
  # eliminación de archivos descargados y extraídos
  archivo_temp <- list.files(
    path = tempdir(),
    pattern = "\\.zip$|\\.csv$|\\.dbf$|\\.dta$|\\.sav$",
    full.names = TRUE,
    ignore.case = TRUE
  )
  
  unlink(archivo_temp)
  
  return(enoe)
}

