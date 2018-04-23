library(readr)
library(ggplot2)
setwd("M:/TBOG/Dark Souls 2/Dark Souls 2 - Chapter 1/")
#	sets the working directory, so files can be read and written just with name
results <- read_csv("Dark Souls 2 - Chapter 1_201804011546 - Edited.csv")
#	reads the CSV of heart-rate date into the results variable.
#	data has already been edited to have the ends not in the video removed.

#Variables
PULSEclean <- results$PULSE[!results$PULSE == 0]
#	BPM == 0 elements are removed (happens when oximeter loses signal)

PULSEframe <- as.data.frame(table(PULSEclean)
#	creates a table of how often certain BPM values were recorded
PULSEframe = data.frame(as.numeric(PULSEframe[, 1]), as.numeric(PULSEframe[, 2]))
#	sets data type of the columns to be numeric
colnames(PULSEframe) <- c("Rate","Count")
#	sets the column names

PULSEcut = subset(PULSEframe, 65 < PULSEframe$Rate & PULSEframe$Rate < 70)
#	makes a subset for BPM between 65 and 70
if (sum(PULSEcut$Count) > 10) {
#	checks how frequently the BPM is between 65 and 70
#	typically BPM in this range is an error, but I assume it is not if it happens over 10 times
	PULSEseq <- seq(from = 65, to = max(PULSEclean, 100), by = 1)
} else {
  PULSEseq <- seq(from = 70, to = max(PULSEclean, 100), by = 1)
}
#	creates the sequence of BPM values for the x-axis, dependant on the appearance of BPM between 65 and 70
							
PULSEcut = subset(PULSEframe, 60 < PULSEframe$Rate & PULSEframe$Rate < 65)
if (sum(PULSEcut$Count) > 10) {
  PULSEseq <- seq(from=60, to=max(PULSEclean,100), by=1)
} else {}
#	same as above, but checks for the 60-65 BPM range
							
#Process
write.table(PULSEframe,file="Dark Souls 2 - Chapter 1 Frequency.txt", sep=",", row.names=FALSE)
#	writes the results of tthe table to a file, but does not add row names
#quantile(PULSEclean, c(.001, .01, .99, 0.999))
#summary(PULSEclean)
#	unnecessary extra processing here for reference if curious

#Time in Video
form = "%H:%M:%S"
#	sets my preferred hh:mm:ss format for time information
times = format(seq(ISOdate(1,1,1, 0), by = "sec", length.out = dim(results)[1]), form)
#	creates a sequence from 00:00:00 to the length of the video, incrementing by 1 second, the resolution of the data
TiV = cbind(times, results[2])
#	TiV is Time in Video
#	creates a frame combining the sequence above with the BPM results
colnames(TiV) = c("Time in Video ","PULSE")
#	sets the column names for the frame to something readable
write_csv(TiV, "Dark Souls 2 - Chapter 1_201804011546 - Timed.csv")
#	creates the CSV file from the TiV frame
							
time = TiV[nrow(TiV), 1]
#	finds the last time of TiV, the length of the video
							
pdf(NULL)
#	to prevent GGPlot from making an undesired pdf

#Graph
ggplot(as.data.frame(PULSEclean), aes(PULSEclean, fill=..count..)) + ggtitle("Dark Souls 2 - Chapter 1", subtitle=paste("Length -", time)) + 
#	initiates the ggplot using PULSEclean, so no erroroneous data, sets the title of the graph, and sets the subtitle to be the length of the video
scale_fill_gradient("Count", low = "#6d59ff", high = "#ab4b41") + 
#	creates a gradient for the Count value, from a blue to red color
stat_bin(binwidth = 1, col="black") + 
#	adds the actual histogram of the data, with a bin width of 1 and black column border
scale_x_continuous(breaks=PULSEseq, name="Heart Rate (bpm)", limits=c(min(PULSEseq) - 1, max(PULSEseq, 101)), minor_breaks=NULL, expand=c(0, 1)) + 
#	sets the x scale using the PULSEseq for breaks, it will assume the labels match the breaks, gives the name, sets the limits on the data, and how far past the data it should expand the graph window
scale_y_continuous(name="Count", expand=c(0.02, 0)) + 
#	sets the y scale to have the name Count and changes how exapnds itself normally for providing a border around the graph
theme_bw()
#	sets the theme to be the built-in black and white theme

ggsave(filename="Dark Souls 2 - Chapter 1 - Hist.png", device="png", width=12.8, height=7.2, dpi=150)
#ggsave(filename="Dark Souls 2 - Chapter 1 - Hist.pdf", device="pdf", width=12.8, height=7.2)
#	commands for saving the graph with the PDF version commented out as only PNG version is needed
