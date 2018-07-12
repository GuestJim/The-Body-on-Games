library(readr)
library(ggplot2)
library(gridExtra)
library(foreach)
library(doParallel)

setwd("!PATH!")
pulse <- read_csv("!FILEX!")
dir.create("!FILE!", showWarnings=FALSE)
setwd("!FILE!")

#Frames for video of full overlay

##covers the BPM axis
PULSEseq = seq(from=70, to=max(pulse$PULSE,100), by=5)

#makes frames with a time column in Seconds
PULSEtime = seq(1:length(pulse$PULSE))
PULSEframe = data.frame(PULSEtime,pulse$PULSE)
colnames(PULSEframe) = c("Time", "Pulse")

#at 1 we have one per frame
count = 1 

#how many previous frames to also show
backPULSE = 60*5 
backWAVE = 5 

registerDoParallel(cores=detectCores() - 4)

foreach (place=seq(from=0, to=length(PULSEtime)-1, by=1), .packages = c("ggplot2", "gridExtra")) %dopar% {

pdf(NULL)

#will modify the theme for all of the plots
theme_update(
panel.background = element_rect(fill="black"),
plot.background = element_rect(fill="black"),
panel.grid.minor=element_line(color="grey20"),
axis.text = element_text(color="white", size=12),
text = element_text(color="white", size=16),
legend.position='none'
)

ggplot(PULSEframe, aes(x=PULSEframe$Time, y=PULSEframe$Pulse, label=PULSEframe$Pulse)) + geom_path(color="yellow",size=2) + geom_point(aes(color=Pulse)) + scale_color_gradient("Pulse", low = "#6d59ff", high = "#ab4b41", limits=c(70,100)) + 
geom_text(label=ifelse(PULSEframe$Time==place, as.character(PULSEframe$Pulse),''), x=place, y=max(PULSEseq,100), vjust=1, hjust=2, size=20, aes(color=Pulse)) + 
scale_y_continuous(labels=PULSEseq, breaks=PULSEseq, name="Heart Rate (bpm)", limits=c(min(PULSEseq),max(PULSEseq,100)), sec.axis=dup_axis(), expand=c(0,0)) + 
scale_x_continuous(name="Time (minutes)", breaks=0:length(PULSEframe$Pulse)*60, labels=0:length(PULSEframe$Pulse), expand=c(0,0), minor_breaks=0:length(PULSEframe$Pulse), limits=c((place-backPULSE)*(count),(place)*(count))) 

ggsave(filename=sprintf("%05d.png",place), device="png", width=12.80, height=7.20, dpi=100)
#aspect ratio should be 780/286 to match original
}
