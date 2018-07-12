library(readr)
#	loads the library for reading CSVs into R
library(ggplot2)
#	loads the GGPlot2 library for generating graphs
library(gridExtra)
#	loads the gridExtra library for placing plots in the desired locations
library(foreach)
library(doParallel)
#	both foreach and doParallel are for making this multithreaded

setwd("!PATH!")
#	sets working directory
pulse <- read_csv("!FILEPulsX!")
wave <- read_csv("!FILEWaveX!",col_names="Data")
#	reads CSVs to the appropriate data frames
dir.create("Combo Overlay - !FILEPuls!", showWarnings=FALSE)
#	creates a folder to save the graphs in
setwd("Combo Overlay - !FILEPuls!")
#	sets the working directory to the folder for the graphs

#Frames for video of full overlay

PULSEseq = seq(from=70, to=max(pulse$PULSE,100), by=5)
#	sets the BPM axis

PULSEtime = seq(1:length(pulse$PULSE))
PULSEframe = data.frame(PULSEtime,pulse$PULSE)
colnames(PULSEframe) = c("Time", "Pulse")
#	makes frames with a time column in seconds, the frequency of the BPM data

WAVEtime = seq(from = 0, to = (length(wave$Data)-1)/60, by = 1/60)
WAVEframe = data.frame(WAVEtime, wave$Data)
colnames(WAVEframe) = c("Time", "Wave")
#	creates a frame with a time column matching the frequency of the wave data, 60 Hz

count = 1 
#	at 1 we have one piece of data per frame

backPULSE = 60 * 5 
backWAVE = 5 
#	how many previous seconds of data to show

registerDoParallel(cores=detectCores() - 4)
#	sets how many threads can be used by detecting the number present and subtracting 4, for continued system usability

foreach (place=seq(from=0, to=length(WAVEtime)-1, by=1), .packages = c("ggplot2", "gridExtra")) %dopar% {
#	the foreach command with %dopar% will spread the work across multiply threads
#	foreach does require any necessary packages by identified, in this case ggplot2

pdf(NULL)
#	to prevent an unnecessary PDF from being made

theme_update(
panel.background = element_rect(fill="black"),
plot.background = element_rect(fill="black"),
panel.grid.minor=element_line(color="grey20"),
axis.text = element_text(color="white", size=12),
text = element_text(color="white", size=16),
legend.position='none'
)
#	will modify the theme for all of the plots

plots = list()
#	creates an empty list to stick the different plots into

placePULSE = floor(place/60)
#	converts the counter from 60 Hz to 1 Hz for the PULSE data, always rounding down

plots[[1]] <- ggplot(PULSEframe, aes(x=PULSEframe$Time, y=PULSEframe$Pulse, label=PULSEframe$Pulse)) + geom_path(color="yellow") + geom_point(aes(color=Pulse)) + 
scale_color_gradient("Pulse", low = "#6d59ff", high = "#ab4b41", limits=c(70,100)) + 
scale_y_continuous(labels=PULSEseq, breaks=PULSEseq, name="Heart Rate (bpm)", minor_breaks=NULL,limits=c(min(PULSEseq),max(PULSEseq,100)), sec.axis=dup_axis(name=NULL), expand=c(0,0)) + 
scale_x_continuous(name="Time (minutes)", breaks=0:length(PULSEframe$Pulse)*60, labels=0:length(PULSEframe$Pulse), expand=c(0,0), minor_breaks=NULL, limits=c((placePULSE-backPULSE)*(count),(placePULSE)*(count))) 
#	the BPM graph

plots[[2]] <- ggplot(PULSEframe, aes(x=PULSEframe$Time, y=PULSEframe$Pulse, label=PULSEframe$Pulse)) + scale_color_gradient("Pulse", low = "#6d59ff", high = "#ab4b41", limits=c(70,100)) + 
geom_text(label=ifelse(PULSEframe$Time==placePULSE, as.character(PULSEframe$Pulse),''), size=10, aes(x=0, y=0,color=Pulse), hjust="inward") + 
scale_x_continuous(labels=NULL, name=NULL, breaks=NULL) + scale_y_continuous(labels=NULL, name=NULL, breaks=NULL)
#	a text display of the current BPM measurement

placeWAVE = place/60 
#	the wave is not in seconds but 1/60 and this converts to that 'unit'

WAVEcurrent = subset(WAVEframe$Wave,(placeWAVE-backWAVE) < WAVEframe$Time & placeWAVE+1/60 > WAVEframe$Time)
#	identifies the section of the WAVE data to be shown, and not all of the WAVE data

MAXframe = data.frame(x=c(max(0,placeWAVE-backWAVE),Inf),y=c(max(WAVEcurrent),max(WAVEcurrent)))
MINframe = data.frame(x=c(max(0,placeWAVE-backWAVE),Inf),y=c(min(WAVEcurrent),min(WAVEcurrent)))
#	finds the minimum and maximum values of the WAVE data in the current section
#	these values are then placed in a wave as x, y coordinates for the use of drawing lines marking the minimum and maximum

plots[[3]] <- ggplot(WAVEframe, aes(x=WAVEframe$Time, y=WAVEframe$Wave)) + 
geom_path(color="yellow") + 
geom_line(aes(x=MAXframe[1], y=MAXframe[2]), data=MAXframe,color="green") + 
geom_line(aes(x=MINframe[1], y=MINframe[2]), data=MINframe,color="green") + 
#geom_segment(x=0,xend=Inf, y=max(WAVEcurrent),yend=max(WAVEcurrent), color="green") + 
#geom_segment(x=0,xend=Inf, y=min(WAVEcurrent),yend=min(WAVEcurrent), color="green") + 
scale_x_continuous(name=NULL, expand=c(0,0), minor_breaks=seq(from=0,to=length(WAVEframe$Wave),by=1), breaks=seq(from=0,to=length(WAVEframe$Wave)/(60/5),by=5), labels=round(seq(from=0,to=length(WAVEframe$Wave)/(60/5),by=5)/60, digits=3), limits=c((placeWAVE-backWAVE)*(count),(placeWAVE)*(count))) + 
scale_y_continuous(labels=NULL, name=NULL, breaks=NULL, expand=c(0,0)) 
#	the actualy WAVE graph

layout=rbind(c(1,1,1,1,1,1,2),c(1,1,1,1,1,1,2),c(3,3,3,3,3,3,3))
#	a frame to map the desired placement of the graphs
#		1,1,1,1,1,1,2
#		1,1,1,1,1,1,2
#		3,3,3,3,3,3,3

grid.arrange(grobs = plots, layout_matrix=layout)
out = arrangeGrob(grobs = plots, layout_matrix=layout)
#	places/fills the graphs into the grid described above
#		Pulse graph (graph 1) fills wherever there is 1
#		Text BPM (graph 2) fills whevever there is 2
#		Wave graph (graph 3) fills wherever there is 3

ggsave(filename=sprintf("%05d.png",place), out, device="png", width=12.00, height=4.40, dpi=100)
#	aspect ratio should be 780/286 to match original
#	creates the graphs
#	sprintf will pad the 'place' variable with 0s to reach so many characters (5 in this case)

dev.off(dev.prev())
#	closes previous devices to ensure they are closed to avoid an error
}
