library(readr)
#	for reading CSVs
library(ggplot2)
#	for creating graphs
library(gridExtra)
#	for arranging separate graphs in a grid
library(foreach)
library(doParallel)
#	both are for enabling Multithreading

setwd("M:/TBOG/Agony/Agony - Part 13/")
#	set working directory
pulse <- read_csv("Agony - Part 13_201806021428 - Edited.csv")
wave <- read_csv("Agony - Part 13_201806021428_wave.csv", col_names="Data")
#	reads in the CSVs to data frames
dir.create("Combo Overlay - Agony - Part 13_201806021428 - Edited", showWarnings=FALSE)
setwd("Combo Overlay - Agony - Part 13_201806021428 - Edited")
#	creates and then sets to work in the directory that will hold the graphs

#Frames for video of full overlay

PULSEseq = seq(from=70, to=max(pulse$PULSE,100), by=5)
#	covers the BPM axis

PULSEtime = seq(1:length(pulse$PULSE))
PULSEframe = data.frame(PULSEtime,pulse$PULSE)
colnames(PULSEframe) = c("Time", "Pulse")
#	makes frames with a time column in Seconds

WAVEtime = seq(from = 0, to = (length(wave$Data)-1)/60, by = 1/60)
WAVEframe = data.frame(WAVEtime, wave$Data)
colnames(WAVEframe) = c("Time", "Wave")
#	the Wave data has a 60 Hz cycle to it while Pulse is 1 Hz, making it necessary to convert

count = 1 
#	at 1 we have one per frame

backPULSE = 60*5 
backWAVE = 5 
#	how many previous frames to also show

registerDoParallel(cores=detectCores() - 4)
#	creates the multiple workers
#	it reads the number of available threads and subtracts 4 so the computer is still usable

foreach (place=seq(from=0, to=length(WAVEtime)-1, by=1), .packages = c("ggplot2", "gridExtra")) %dopar% {
#	foreach with %dopar% will assign the different workers to do this work
#	the packages that will be used inside the loop must be specified

pdf(NULL)
#	to prevent a generic PDF from being made
	
theme_update(
panel.background = element_rect(fill="black"),
plot.background = element_rect(fill="black"),
panel.grid.minor=element_line(color="grey20"),
axis.text = element_text(color="white", size=12),
text = element_text(color="white", size=16),
legend.position='none'
)
#	modifies the theme of the graphs to

plots = list()
#	a list to hold the plots in for later calling

placePULSE = floor(place/60)
#	to keep the timing between the Wave (60 Hz) and Pulse (1 Hz) data in sync

plots[[1]] <- ggplot(PULSEframe, aes(x=PULSEframe$Time, y=PULSEframe$Pulse, label=PULSEframe$Pulse)) + geom_path(color="yellow") + geom_point(aes(color=Pulse)) + 
scale_color_gradient("Pulse", low = "#6d59ff", high = "#ab4b41", limits=c(70,100)) + 
scale_y_continuous(labels=PULSEseq, breaks=PULSEseq, name="Heart Rate (bpm)", minor_breaks=NULL,limits=c(min(PULSEseq),max(PULSEseq,100)), sec.axis=dup_axis(name=NULL), expand=c(0,0)) + 
scale_x_continuous(name="Time (minutes)", breaks=0:length(PULSEframe$Pulse)*60, labels=0:length(PULSEframe$Pulse), expand=c(0,0), minor_breaks=NULL, limits=c((placePULSE-backPULSE)*(count),(placePULSE)*(count))) 
#	graph of the Pulse over time
	
plots[[2]] <- ggplot(PULSEframe, aes(x=PULSEframe$Time, y=PULSEframe$Pulse, label=PULSEframe$Pulse)) + scale_color_gradient("Pulse", low = "#6d59ff", high = "#ab4b41", limits=c(70,100)) + 
geom_text(label=ifelse(PULSEframe$Time==placePULSE, as.character(PULSEframe$Pulse),''), size=10, aes(x=0, y=0,color=Pulse), hjust="inward") + 
scale_x_continuous(labels=NULL, name=NULL, breaks=NULL) + scale_y_continuous(labels=NULL, name=NULL, breaks=NULL)
#	the value of the current Pulse datum

placeWAVE = place/60 
#	placeWAVE is in seconds. place is a unitless counter. Dividing place by 60 Hz gives us seconds

WAVEcurrent = subset(WAVEframe$Wave,(placeWAVE-backWAVE) < WAVEframe$Time & placeWAVE+1/60 > WAVEframe$Time)
#	the section of the wave to be shown
	
MAXframe = data.frame(x=c(max(0,placeWAVE-backWAVE),Inf),y=c(max(WAVEcurrent),max(WAVEcurrent)))
MINframe = data.frame(x=c(max(0,placeWAVE-backWAVE),Inf),y=c(min(WAVEcurrent),min(WAVEcurrent)))
#	gets the min and max of the WAVE current values
	
plots[[3]] <- ggplot(WAVEframe, aes(x=WAVEframe$Time, y=WAVEframe$Wave)) + 
geom_path(color="yellow") + 
geom_line(aes(x=MAXframe[1], y=MAXframe[2]), data=MAXframe,color="green") + 
geom_line(aes(x=MINframe[1], y=MINframe[2]), data=MINframe,color="green") + 
scale_x_continuous(name=NULL, expand=c(0,0), minor_breaks=seq(from=0,to=length(WAVEframe$Wave),by=1), breaks=seq(from=0,to=length(WAVEframe$Wave)/(60/5),by=5), labels=round(seq(from=0,to=length(WAVEframe$Wave)/(60/5),by=5)/60, digits=3), limits=c((placeWAVE-backWAVE)*(count),(placeWAVE)*(count))) + 
scale_y_continuous(labels=NULL, name=NULL, breaks=NULL, expand=c(0,0)) 
#	graph of the wave data for a certain section
#	green lines are drawn to show the min and max of the wave
#		the wave represents the recorded blood flow, and so it also relates to blood pressure
	
layout=rbind(c(1,1,1,1,1,1,2),c(1,1,1,1,1,1,2),c(3,3,3,3,3,3,3))
#	creates the grid layout
#		plot 1 spans wherever 1 is
#		plot 2 spans wherever 2 is
#		plot 3 spans wherever 3 is
grid.arrange(grobs = plots, layout_matrix=layout)
out = arrangeGrob(grobs = plots, layout_matrix=layout)
#	places the plots into the grid and then assigns this output to the 'out' variable
	
ggsave(filename=sprintf("%06d.png",place), out, device="png", width=12.00, height=4.40, dpi=100)
#	is what actually saves the graph
#		%06d means it will name the files with padding zeroes
#	aspect ratio should be 780/286 to match original

dev.off(dev.prev())
#	saving an image involves creating a device to do so and this closes the previous one
#		this is necessary to prevent R from throwing an error about too many devices
}
