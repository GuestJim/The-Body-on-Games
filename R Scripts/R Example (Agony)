library(readr)
#	loads the library for reading CSVs into R
library(ggplot2)
#	loads the GGPlot2 library for generating graphs
setwd("M:/TBOG/Agony/Agony - Part 01/")
#	sets the working directory, so files can be read and written just with name
results <- read_csv("Agony - Part 01_201805301104 - Edited.csv")
#	reads the CSV of heart-rate date into the results variable.
#	data has already been edited to have the ends not in the video removed.

DPI = 120
ggscale = 1
#	sets the DPI for the output and the scale factor for ggsave
#		120 gives 1920x1080 as dimensions are 16 x 9

Tsize = 16
#	sets the Text size

#Variables
PULSEclean <- results$PULSE[!results$PULSE == 0]
#	BPM == 0 elements are removed (happens when oximeter loses signal)
PULSEframe <- as.data.frame(table(PULSEclean)
#	creates a table of how often certain BPM values were recorded
PULSEframe = data.frame(as.numeric(PULSEframe[, 1]), as.numeric(PULSEframe[, 2]))
#	sets data type of the columns to be numeric
colnames(PULSEframe) <- c("Rate","Count")
#	sets the column names

#Process
write.table(PULSEframe, file="Agony - Part 01 Frequency.txt", sep = ",", row.names = FALSE)
#	creates a table with the counts at each BPM
							
#Time in Video
form = "%H:%M:%S"
#	sets the HH:MM:SS format for time
times = format(seq(ISOdate(1,1,1, 0), by = "sec", length.out = nrow(results)), form)
#	creates a sequence from 0:0:0 to the end of the video, incrementing by 1 second
TiV = cbind(times, results[2])
#	Time in Video
#	creates a frame combining the times with the BPM values
colnames(TiV) = c("Time in Video", "PULSE")
#	sets the column names of the TiV frame
write_csv(TiV, "Agony - Part 01_201805301104 - Timed.csv")
#	writes a CSV of the TiV frame

time = TiV[nrow(TiV), 1]
#	finds the length of the data/video

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

PULSEquart = quantile(PULSEclean, c(.25, .50, .75))
#	creates a vector of the 25%, 50% (median), and 75% percentiles
LABELquart = c("25%", "Median", "75%")
#	creates a vector for labeling the percentiles on the graph
							
pdf(NULL)
#	to prevent GGPlot from making an undesired pdf
							
#Graph
ggplot(as.data.frame(PULSEclean), aes(PULSEclean, fill=..count..)) + ggtitle("Agony - Part 01", subtitle=paste("Length - ", time)) + 
#	initiates the ggplot using PULSEclean, so no erroroneous data, sets the title of the graph, and sets the subtitle to be the length of the video
scale_fill_gradient("Count", low = "#6d59ff", high = "#ab4b41") + 
#	creates a gradient for the Count value, from a blue to red color
geom_vline(xintercept = PULSEquart, size = 2) + 
#	adds vertical lines at 25%, 50% (median), and 75%
#	with size = 2 the lines are thicker and more obvious
stat_bin(binwidth = 1, col = "black") + 
#	adds the actual histogram of the data, with a bin width of 1 and black column border
#	by being after the geom_vline, the columns will cover the lines
scale_x_continuous(breaks = PULSEseq, name = "Heart Rate (bpm)", limits=c(min(PULSEseq) - 1, max(PULSEseq, 101)), minor_breaks = NULL, expand = c(0, 1), sec.axis = sec_axis(trans = ~., breaks = PULSEquart, labels = LABELquart)) + 
#	sets the x scale using the PULSEseq for breaks, it will assume the labels match the breaks, gives the name, sets the limits on the data, and how far past the data it should expand the graph window
#	the sec.axis adds a second axis at the top of the graph, just to identify the values of the percentiles
scale_y_continuous(name = "Count", expand = c(0.02, 0)) + 
#	sets the y scale to have the name Count and changes how exapnds itself normally for providing a border around the graph
theme_bw(base_size = Tsize)
#	sets the theme to be the built-in black and white theme
#	changes the base size to Tsize, allowing the text size to be increased

ggsave(filename="Agony - Part 01 - Hist.png", device="png", width=16, height=9, dpi=DPI, scale = ggscale)
#ggsave(filename="Agony - Part 01 - Hist.pdf", device="pdf", width=16, height=9)
#	commands for saving the graph with the PDF version commented out as only PNG version is needed
#	the DPI and ggscale variables are set above to control the size and density of the image
