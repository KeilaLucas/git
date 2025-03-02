# ------------------------- SCRIP PARA LER INTERNA��ES HOSPITALARES DO BRASIL ---------------------
# Author: F�bio Jr Silva

#Adaptado: Keila Lucas (Casos da Para�ba)
#Usar apenas os dados da Para�ba
#Corrigir o per�odo de Sele��o.


# instala��o dos pacotes requeridos
install.packages("read.dbc")
install.packages("stringr")
install.packages("lubridate")

# Importa��o das bibliotecas para dentro desse Script
library(read.dbc)
library(lubridate)
library(stringr)

# --------------------------- OBSERVA��O --------------------------------------------------------------
# Antes de continuar � necess�rio entrar no site do DATASUS.
# link: http://www2.datasus.gov.br/DATASUS/index.php?area=0901&item=1&acao=25.
# Baixar os arquivos das interna��es hospitalares por estado, ano, ou m�s como est� dispon�vel.
# Descompactar os arquivos baixados em uma pasta no seu computador.
#------------------------------------------------------------------------------------------------------

# Caminho da pasta onde est�o os arquivos de interna��es hospitalares baixados do DATASUS
setwd("C:/AIH")


# Deixe na lista abaixo apenas os estados que voc� baixou no siste do DATASUS, apague o resto
ufs = c('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 
        'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 
        'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 
        'SP', 'SE', 'TO')


# Bases de dados tempor�rios
internacoes = NULL
InterBR = NULL


# Estrutura de repeti��o para pegar todos os estados informados acima
for(uf in 1:NROW(ufs)){ # < -- DEIXE O CURSOSR EM CIMA DESSE for e aperte ctrl + Enter para executar
  
  rduf = paste('RD',ufs[uf], sep='') # Concatena "RD" com a sigla do estado

# ------------------------------------ CONFIGURA��O NECESS�RIA ---------------------------------------
  data_inicial = ymd("2009-01-01") # <-- Informe a data inicial no padr�o americano yyyy-mm-dd
  data_final = ymd("2018-10-30") # <-- Informe a data final no padr�o americano yyyy-mm-dd
# ---------------------------------------------------------------------------------------------------- 
  
  # VAri�vei que vai avan�ar conforme se alteram os meses 
  data_corrente = data_inicial
  
  
  # Estrutura de repeti��o para percorrer o per�odo
  while (data_corrente < data_final){
   
      # Concatena 0 com i para ter o mome do arquivo com o ano
      ano = paste(str_sub(as.character(year(data_corrente)), start = 3), sep='')
      
      
      # concatena 0 com j para ter o nome do arquivo com mes
      if (month(data_corrente) < 10){
        mes = paste('0', month(data_corrente), sep='')
      } else{
        mes = paste('', month(data_corrente), sep='')
      }
      
      # Forma��o do nome do arquivo no padr�o RDPBAAMM.dbc
      nomeDateBase = paste(rduf, ano, mes, '.dbc', sep='')
      
      # log com o nome do arquivo que ser� lido
      print(nomeDateBase)
      
      # L� um arquivo e cria uma base de dados
      df = read.dbc(nomeDateBase)

# ------------------------------------------------  CONFIGURA��O -------------------------------------     
      # Informe o nome das colunas que voc� deseja selecionar para seu estudos
      newdf = df[c('MUNIC_RES', 'CEP', 'IDENT', 'ESPEC', 'INSTRU','SEXO', 'COD_IDADE', 'IDADE', 
                   'DT_INTER', 'DIAG_PRINC', 'DIAS_PERM','CAR_INT', 'PROC_SOLIC', 'RACA_COR')]
      
      # Informe o CID-10 que voc� deseja selecionar
      iPd = subset(newdf, DIAG_PRINC=='A90')
# ---------------------------------------------------------------------------------------------------
      
      internacoes = rbind(iPd, internacoes)
      data_corrente = data_corrente + ddays(as.integer(days_in_month(data_corrente)))
      
 
 } # Fim da estrutura de repeti��o para o per�odo
  
  # Mostra o n�mero de interna��es por estado no per�odo analizado
  print(paste(ufs[uf], ' Teve ', nrow(internacoes), ' Interna��es', sep=''))
  
  # As interna�oes dos estados e per�odo selecionado
  InterBR = rbind(InterBR, internacoes) 
 
} # Fim da estrutura de repeti��o que carrega os estados


# Escreve um arquivo .csv sem os nomes das colunas selecionadas acima
write.csv(baseTemp, file = "Internacoes_BR.csv", row.names=FALSE)
