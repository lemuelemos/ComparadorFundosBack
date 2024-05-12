BaixarInformeDiario <- function(anos_download = NULL,meses_download = NULL){

  if(is.null(anos_download)) anos_download <- unique(format(seq(as.Date("2005-01-01"),
                                                                as.Date("2020-12-31"),
                                                                by = "month"),"%Y"))

  if(is.null(meses_download)) meses_download <- format(seq(as.Date("2021-01-01"),
                                                           as.Date("2024-03-31"),
                                                           by = "month"),
                                                       "%Y%m")


  #### Download dados informes diários #####

  print("Baixando informes diários")

  future::plan(future::multisession, workers = 4)

  furrr::future_map(anos_download, function(ano){
    url <- paste0("https://dados.cvm.gov.br/dados/FI/DOC/INF_DIARIO/DADOS/HIST/inf_diario_fi_",ano,".zip")
    destfile <- paste0("./inst/extdata/",ano,".zip")
    utils::download.file(url,destfile)
  })

  furrr::future_map(meses_download, function(mes){
    url <- paste0("https://dados.cvm.gov.br/dados/FI/DOC/INF_DIARIO/DADOS/inf_diario_fi_",mes,".zip")
    destfile <- paste0("./inst/extdata/",mes,".zip")
    utils::download.file(url,destfile)
  })


  #### Dezipando dados informes diários #####

  print("Dezipando informes diarios")

  zipfiles <- list.files("./inst/extdata/",full.names = T)

  furrr::future_map(zipfiles,function(path){
    utils::unzip(path,exdir = "./inst/extdata/")
  })

  future::plan(future::sequential)
  file.remove(zipfiles)

  #### Lendo os dados informes diários #####

  print("Lendo informes diarios")

  informes_path <- list.files("./inst/extdata/",full.names = T,pattern = ".csv")

  future::plan(future::multisession, workers = 4)

  furrr::future_map(informes_path,function(informe){
    readr::read_delim(informe,
                      delim = ";",
                      escape_double = FALSE,
                      col_types = readr::cols(DT_COMPTC = readr::col_date(format = "%Y-%m-%d")),
                      locale = readr::locale(),
                      trim_ws = TRUE)
  }) -> informe_diario_fundos

  future::plan(future::sequential)
  file.remove(informes_path)

  print("Juntando Meses")
  dplyr::bind_rows(informe_diario_fundos) -> informe_diario_fundos

  print("Salvando informes diários")
  pool::dbWriteTable(pool(),"informe_diario_fundos", informe_diario_fundos, overwrite = TRUE)

}
