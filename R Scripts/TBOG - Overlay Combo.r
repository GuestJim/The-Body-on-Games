library(readr)
library(ggplot2)
library(gridExtra)
library(foreach)
library(doParallel)

setwd("!PATH!")
pulse <- read_csv("!FILEPulsX!")
wave <- read_csv("!FILEWaveX!",col_names="Data")
dir.create("Combo Overlay - !FILEPuls!", showWarnings=FALSE)
setwd("Combo Overlay - !FILEPuls!")

#Frames for video of full overlay

##covers the BPM axis
PULSEseq = seq(from=70, to=max(pulse$PULSE,100), by=5)

#makes frames with a time column in Seconds
PULSEtime = seq(1:length(pulse$PULSE))
PULSEframe = data.frame(PULSEtime,pulse$PULSE)
colnames(PULSEframe) = c("Time", "Pulse")

WAVEtime = seq(from = 0, to = (length(wave$Data)-1)/60, by = 1/60)
WAVEframe = data.frame(WAVEtime, wave$Data)
colnames(WAVEframe) = c("Time", "Wave")

#at 1 we have one per frame
count = 1 

#how many previous frames to also show
backPULSE = 60*5 
backWAVE = 5 

registerDoParallel(cores=detectCores() - 4)

foreach (place=seq(from=0, to=length(WAVEtime)-1, by=1), .packages = c("ggplot2", "gridExtra")) %dopar% {

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

plots = list()

placePULSE = floor(place/60)

plots[[1]] <- ggplot(PULSEframe, aes(x=PULSEframe$Time, y=PULSEframe$Pulse, label=PULSEframe$Pulse)) + geom_path(color="yellow") + geom_point(aes(color=Pulse)) + 
scale_color_gradient("Pulse", low = "#6d59ff", high = "#ab4b41", limits=c(70,100)) + 
scale_y_continuous(labels=PULSEseq, breaks=PULSEseq, name="Heart Rate (bpm)", minor_breaks=NULL,limits=c(min(PULSEseq),max(PULSEseq,100)), sec.axis=dup_axis(name=NULL), expand=c(0,0)) + 
scale_x_continuous(name="Time (minutes)", breaks=0:length(PULSEframe$Pulse)*60, labels=0:length(PULSEframe$Pulse), expand=c(0,0), minor_breaks=NULL, limits=c((placePULSE-backPULSE)*(count),(placePULSE)*(count))) 

plots[[2]] <- ggplot(PULSEframe, aes(x=PULSEframe$Time, y=PULSEframe$Pulse, label=PULSEframe$Pulse)) + scale_color_gradient("Pulse", low = "#6d59ff", high = "#ab4b41", limits=c(70,100)) + 
geom_text(label=ifelse(PULSEframe$Time==placePULSE, as.character(PULSEframe$Pulse),''), size=10, aes(x=0, y=0,color=Pulse), hjust="inward") + 
scale_x_continuous(labels=NULL, name=NULL, breaks=NULL) + scale_y_continuous(labels=NULL, name=NULL, breaks=NULL)

placeWAVE = place/60 

WAVEcurrent = subset(WAVEframe$Wave,(placeWAVE-backWAVE) < WAVEframe$Time & placeWAVE+1/60 > WAVEframe$Time)

MAXframe = data.frame(x=c(max(0,placeWAVE-backWAVE),Inf),y=c(max(WAVEcurrent),max(WAVEcurrent)))
MINframe = data.frame(x=c(max(0,placeWAVE-backWAVE),Inf),y=c(min(WAVEcurrent),min(WAVEcurrent)))

plots[[3]] <- ggplot(WAVEframe, aes(x=WAVEframe$Time, y=WAVEframe$Wave)) + 
geom_path(color="yellow") + 
geom_line(aes(x=MAXframe[1], y=MAXframe[2]), data=MAXframe,color="green") + 
geom_line(aes(x=MINframe[1], y=MINframe[2]), data=MINframe,color="green") + 
#geom_segment(x=0,xend=Inf, y=max(WAVEcurrent),yend=max(WAVEcurrent), color="green") + 
#geom_segment(x=0,xend=Inf, y=min(WAVEcurrent),yend=min(WAVEcurrent), color="green") + 
scale_x_continuous(name=NULL, expand=c(0,0), minor_breaks=seq(from=0,to=length(WAVEframe$Wave),by=1), breaks=seq(from=0,to=length(WAVEframe$Wave)/(60/5),by=5), labels=round(seq(from=0,to=length(WAVEframe$Wave)/(60/5),by=5)/60, digits=3), limits=c((placeWAVE-backWAVE)*(count),(placeWAVE)*(count))) + 
scale_y_continuous(labels=NULL, name=NULL, breaks=NULL, expand=c(0,0)) 

layout=rbind(c(1,1,1,1,1,1,2),c(1,1,1,1,1,1,2),c(3,3,3,3,3,3,3))
grid.arrange(grobs = plots, layout_matrix=layout)
out = arrangeGrob(grobs = plots, layout_matrix=layout)

ggsave(filename=sprintf("%05d.png",place), out, device="png", width=12.00, height=4.40, dpi=100)
#aspect ratio should be 780/286 to match original

dev.off(dev.prev())
}
