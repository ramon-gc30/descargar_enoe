# Obtener todos los módulos ===================================================

descargar_enoe <- function(url){
  
  # Datos de entrada ----
  
  # Almacena la ruta del directorio temporal
  dir_temp <- tempdir(check = TRUE)
  
  # Crea un archivo temporal que contendrá el archivo descargado
  archivo_temp <- tempfile(tmpdir = dir_temp, fileext = ".zip")
  
  # Proceso de descarga ----
  
  # tiempo máximo de descarga 15 min
  options(timeout = max(900, getOption("timeout")))
  
  download.file(url, destfile = archivo_temp) # descarga
  
  # ruta del archivo comprimido
  archivo_temp <- list.files(dir_temp, pattern = "\\.zip$", full.names = TRUE)
  
  # proceso de extracción ----
  
  # lo almacena en el directorio temporal
  unzip(zipfile = archivo_temp, exdir = dir_temp)
  
  # proceso de carga ----
  
  # ruta de los archivos extraídos
  enoe <- list.files(dir_temp, pattern = "\\.csv", full.names = TRUE)
  
  # para la lista
  nombres <- basename(enoe)
  
  nombres <- sub(
    x = nombres,
    pattern = "ENOE_", # se elimina prefijo ENOE
    replacement = ""
  ) 
  
  nombres <- sub(
    x = nombres,
    pattern = ".csv",
    replacement = "" # se elimina extensión
  ) 
  
  # se crea lista que contiene todos los módulos
  enoe <- enoe |> 
    set_names(nm = nombres) |> 
    map(
      \(enoe)
      readr::read_csv(
        file = enoe,
        col_types = cols(.default = col_character())
      )
    )
  
  # proceso de eliminación ----
  
  # ruta de archivos descargados
  archivo_temp <- list.files(
    dir_temp, 
    pattern = "\\.zip$|\\.csv$", 
    full.names = TRUE
  )
  
  # eliminación de archivos descargados
  unlink(archivo_temp) 
  
  # eliminación de objetos creados
  # remove(list = c("archivo_temp", "dir_temp", "enoe", "url")) 
  
  return(enoe)
  
}

# Obtener solamente un módulo =================================================

descargar_modulo <- 
  function(url, modulo = c("hog", "viv", "sdem", "coe1", "coe2"))
{
  # Datos de entrada ----
  
  # Almacena la ruta del directorio temporal
  dir_temp <- tempdir(check = TRUE)
  
  # Crea un archivo temporal que contendrá el archivo descargado
  archivo_temp <- tempfile(tmpdir = dir_temp, fileext = ".zip")
  
  # Proceso de descarga ----
  # tiempo máximo de descarga 15 min
  options(timeout = max(900, getOption("timeout")))
  
  download.file(url, destfile = archivo_temp) # descarga
  
  # ruta del archivo comprimido
  archivo_temp <- list.files(dir_temp, pattern = "\\.zip$", full.names = TRUE)
  
  # lista de los microdatos comprimidos
  microdatos <- unzip(archivo_temp, list = TRUE)$Name
  
  unzip(
    archivo_temp, 
    # modulo especifico
    files = grepv(modulo, microdatos, ignore.case = TRUE),
    exdir = dir_temp
  )
  
  # Proceso de carga ----
  # ruta del archivo extraído
  microdatos <- list.files(dir_temp, pattern = "\\.csv", full.names = TRUE)
  
  microdatos <- read_csv(microdatos, col_types = cols(.default = col_character()))
  
  # Proceso de eliminación ----
  # archivos descargados
  archivo_temp <- list.files(dir_temp, pattern = "\\.zip$|\\.csv$", full.names = TRUE)
  unlink(archivo_temp)
  
  # objetos creados
  # remove(list = c("archivo_temp", "modulo", "dir_temp", "url"))
  
  return(microdatos)
  }

# Obtener todos los módulos sin enlace ========================================
# arregla la función `importinegi::enoe`

descargar_enoe_n <- function(year, trimestre, formato)
{
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
    full.names = TRUE
  )
  
  # nombre para la lista
  nombres <- basename(archivo_temp)
  
  nombres <- sub(
    x = nombres,
    pattern = "ENOE_",
    replacement = ""
  )
  
  nombres <- sub(
    x = nombres,
    pattern = "\\.csv|\\.dbf|\\.dta|\\.sav",
    replacement = ""
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
  
  # eliminación de archivos descargados y extraídos
  archivo_temp <- list.files(
    path = tempdir(),
    pattern = "\\.zip$|\\.csv$|\\.dbf$|\\.dta$|\\.sav$",
    full.names = TRUE
  )
  
  unlink(archivo_temp)
  
  return(enoe)
}