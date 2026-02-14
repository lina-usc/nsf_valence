library(jsonlite)
library(readxl)
# install.packages("rPraat")
library(rPraat)
library(dplyr)


Dir_github <- 'X:/PROJECTS/ABC@UofSC/3-Experiments/NSF_valence/github'
repo <- 'ABC_valence'
pipeline <- 'segmentation_Anyssa'
Dir_timestamps <- paste(Dir_github,'/derivatives/behavioral/timestamps/audacity_labels/doublechecked',sep='')
Dir_output <- paste(Dir_github,'/derivatives/behavioral/audioclips',sep='')
Dir_audio <- 'X:/PROJECTS/ABC@UofSC/3-Experiments/Affective_narrative/Audio_normalized/Normalized/English_language'
List_files <- dir(Dir_timestamps)
List_files <- List_files[grepl("labels", List_files)]
#List_files <- gsub("^timestamps_|\\.csv$", "", List_files)
List_files <- c("Brandi_Elvis")



#df <- read.table("filename.txt", header = TRUE, sep = "\t", stringsAsFactors = FALSE)


###################################
for (taskName in List_files) {
  print(taskName)
  #taskName = "Allison_AgedMother"
  outDir  <- paste(Dir_output,'/',taskName,sep = '')
  
  ################## Cut sounds
  if (file.exists(outDir)){
    setwd(outDir)
  } else {
    dir.create(outDir)
    setwd(outDir)
  }
  
  file_path <- paste(Dir_timestamps,'/labels_',taskName,'_XY.txt',sep='')
  df <- data.frame(read.csv(file_path, sep='\t',header=FALSE))
  colnames(df) <- c('onset','offset','label')
  sndwav <- snd.read(paste(Dir_audio,'/',taskName,'.wav',sep=''))
  sndwav$fs #What Hz
  sndwav$nChannels
  sndwav$nSamples
  sndwav$duration
  
  for (i in 1:nrow(df)) {
    snd <- snd.cut(sndwav, Start = df[i,'onset'], End = df[i,'offset'])
    #snd.plot(snd)
    if (i<10) {
      id <- paste('00',as.character(i),sep='')
    } else if ((i>=10) && (i<100)) {
      id <- paste('0',as.character(i),sep='')
    } else {
      id <- as.character(i)
    }
    snd.write(snd, paste(taskName,"_", id, ".mp3", sep = ""))
  }
}

