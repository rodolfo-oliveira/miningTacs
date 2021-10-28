#script pra minerar tacs


library(jsonlite)
library(httr)

data_inicio <- '2015-1'
data_fim <- '2021-10'
passo <- 500


aux <- fromJSON(txt = paste0('https://consultaspublicas.mpes.mp.br/api/atividadeFim?idAtividade=1&pInicio=0&pFim=',
                             passo,
                             '&numero=&dataInicio=',
                             data_inicio,
                             '&dataFim=',
                             data_fim))

total <- aux$total
aux <- aux$result

final <- aux
if(length(final)<total){
  for(k in 1:ceiling(total/passo)-1){
    Sys.sleep(0.5)
    aux <- fromJSON(txt = paste0('https://consultaspublicas.mpes.mp.br/api/atividadeFim?idAtividade=1&pInicio=',
                                 passo*k,
                                 '&pFim=',
                                 passo*(k+1),
                                 '&numero=&dataInicio=',
                                 data_inicio,
                                 '&dataFim=',
                                 data_fim))
    
    aux <- aux$result
    final <- rbind(final,aux)

  }
}

dir.create("arquivos")

for (k in 1:length(final$idMovimento)) {
  
  if(final$temArquivo[k]==T){
    
    aux <- headers(GET(url = paste0('https://consultaspublicas.mpes.mp.br/api/atividadeFim/', final$idMovimento[k], '/download')))
    
    extension <- stringr::str_extract(aux$`content-disposition`,'\\.[[:alpha:]]+')
    
    tryCatch(expr = download.file(url = paste0('https://consultaspublicas.mpes.mp.br/api/atividadeFim/', 
                                                      final$idMovimento[k], 
                                                      '/download'), 
                                         destfile = paste0('arquivos/',
                                                           final$idMovimento[k],extension)),

                    error = function(e) print(paste(final$idMovimento[k], 'did not work out'))) 
    
    if(file.exists(paste0('arquivos/',final$idMovimento[k],extension))) final$nome_arquivo <- file.path(paste0('arquivos/',
                                                                                                               final$idMovimento[k],extension))
    
    
  }
  
  
}

write.csv2(final, "ref_Tacs.csv")


