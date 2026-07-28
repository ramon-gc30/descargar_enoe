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
