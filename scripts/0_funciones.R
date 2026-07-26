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
  
  # cuestionario de ocupación y empleo 1
  coe1 <- read_csv(
    grepv("coe1", enoe, ignore.case = TRUE),
    col_types = cols(.default = col_character())
  )
  
  # cuestionario de ocupación y empleo 2
  coe2 <- read_csv(
    grepv("coe2", enoe, ignore.case = TRUE),
    col_types = cols(.default = col_character())
  )
  
  # hogar
  hog <- read_csv(
    grepv("hog", enoe, ignore.case = TRUE), 
    col_types = cols(.default = col_character())
  )
  
  # sociodemográfico
  sdem <- read_csv(
    grepv("sdem", enoe, ignore.case = TRUE),
    col_types = cols(.default = col_character())
  )
  
  # vivienda
  viv <- read_csv(
    grepv("viv", enoe, ignore.case = TRUE), 
    col_types = cols(.default = col_character())
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
  
  enoe <- list(
    coe1 = coe1, 
    coe2 = coe2, 
    hog = hog, 
    sdem = sdem, 
    viv = viv
  )
  
  return(enoe)
  
}

# Obtener solamente un módulo =================================================

descargar_microdatos_enoe <- 
  function(url, cuestionario = c("hog", "viv", "sdem", "coe1", "coe2"))
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
    # cuestionario especifico
    files = grepv(cuestionario, microdatos, ignore.case = TRUE),
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
  # remove(list = c("archivo_temp", "cuestionario", "dir_temp", "url"))
  
  return(microdatos)
}
