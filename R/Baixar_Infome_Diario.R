BaixarInformeDiario <- function(anos_download = NULL,meses_download = NULL){

  if(is.null(anos_download)) anos_download <- unique(format(seq(as.Date("2005-01-01"),
                                                                as.Date("2020-12-31"),
                                                                by = "month"),"%Y"))

  if(is.null(meses_download)) meses_download <- format(seq(as.Date("2021-01-01"),
                                                           as.Date("2024-03-31"),
                                                           by = "month"),
                                                       "%Y%m")


  #### Download dados informes diários #####

  plan(multisession, workers = 6)
  future_map(anos_download, function(ano){
    url <- paste0("https://dados.cvm.gov.br/dados/FI/DOC/INF_DIARIO/DADOS/HIST/inf_diario_fi_",ano,".zip")
    destfile <- paste0("./inst/extdata/",ano,".zip")
    download.file(url,destfile)
  })

  future_map(meses_download, function(mes){
    url <- paste0("https://dados.cvm.gov.br/dados/FI/DOC/INF_DIARIO/DADOS/inf_diario_fi_",mes,".zip")
    destfile <- paste0("./inst/extdata/",mes,".zip")
    download.file(url,destfile)
  })


  #### Dezipando dados informes diários #####

  zipfiles <- list.files("./dados/informes_diarios/",full.names = T)

  future_map(zipfiles,function(path){
    unzip(path,exdir = "./dados/informes_diarios/")
  })

  plan(sequential)
  file.remove(zipfiles)

  #### Lendo os dados informes diários #####

  informes_path <- list.files("./dados/informes_diarios/",full.names = T,pattern = ".csv")

  plan(multisession, workers = 6)
  future_map(informes_path,function(informe){
    readr::read_delim(informe,
                      delim = ";",
                      escape_double = FALSE,
                      col_types = readr::cols(DT_COMPTC = readr::col_date(format = "%Y-%m-%d")),
                      locale = readr::locale(),
                      trim_ws = TRUE)
  }) -> informe_diario_fundos


  bind_rows(informe_diario_fundos) -> informe_diario_fundos

  dbplyr::write_table(informe_diario_fundos, "informe_diario_fundos", con = pool(), overwrite = TRUE)

}
