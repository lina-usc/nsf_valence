library(jsonlite)
Dir_github <- 'X:/PROJECTS/ABC@UofSC/3-Experiments/NSF_valence/github'
project <- 'nsf_valence'
pipeline <- 'segmentation_Anyssa'
Dir_segments = paste(Dir_github,'/',project,'/',pipeline,'/segmentation',sep='')
Dir_output = paste(Dir_github,'/output/',pipeline,'/audioclips',sep='')

Dir_audio = 'X:/PROJECTS/ABC@UofSC/3-Experiments/Affective_narrative/Audio_normalized/Normalized/English_language'

###################################
taskName = "Jack_Elvis"
#curDir  <- dirname(rstudioapi::getSourceEditorContext()$path)
#Dir_timestamps <- paste(Dir_project,'/timestamps',sep='')
setwd(Dir_segments)

#folder <- 'AudioClips'
outDir  <- paste(Dir_output,'/',taskName,sep = '')
library(readxl)
# install.packages("rPraat")
library(rPraat)
library(dplyr)

################## Cut sounds
if (file.exists(outDir)){
  setwd(outDir)
} else {
  dir.create(outDir)
  setwd(outDir)
}




################## Data checking

file_path <- paste(Dir_segments,'/',taskName,'.json',sep='')
df <- fromJSON(file_path, flatten = TRUE)
df <- data.frame(df['fragments'])

onsets <- data.frame(read_excel(paste(Dir_timestamps,'/timestamps_',taskName,'_revised.xlsx', sep='')))

#sndwav <- snd.read(paste('E:/phd/project/Nastase/stimuli/',taskName,"_audio.wav",sep=''))
sndwav <- snd.read(paste(Dir_audio,'/',taskName,'.wav',sep=''))
sndwav$fs #What Hz
sndwav$nChannels
sndwav$nSamples
sndwav$duration

for (i in 1:nrow(df)) {
  snd <- snd.cut(sndwav, Start = df['fragments.begin'][i], End = df['end'][i])
  #snd.plot(snd)
  if (i<10) {
    id <- paste('00',as.character(i),sep='')
  } else if ((i>=10) && (i<100)) {
    id <- paste('0',as.character(i),sep='')
  } else {
    id <- as.character(i)
  }
  snd.write(snd, paste(taskName, id, ".wav", sep = ""))
}


