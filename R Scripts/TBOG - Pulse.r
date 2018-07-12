library(readr)
library(ggplot2)
setwd("!PATH!")
results <- read_csv("!FILEX!")

pdf = FALSE
DPI = 120
ggscale = 1 
Tsize = 16

#Variables
PULSEclean <- results$PULSE[!results$PULSE == 0]
PULSEframe <- as.data.frame(table(PULSEclean))
PULSEframe[, 1] = as.character(PULSEframe[, 1])
PULSEframe = data.frame(as.numeric(PULSEframe[, 1]),as.numeric(PULSEframe[, 2]))
colnames(PULSEframe) <- c("Rate","Count")

#Process
write.table(PULSEframe, file="!FILE! Frequency.txt", sep = ",", row.names = FALSE)
#quantile(PULSEclean, c(.001, .01, .99, 0.999))
#summary(PULSEclean)

#Time in Video
form = "%H:%M:%S"
times = format(seq(ISOdate(1,1,1, 0), by = "sec", length.out = nrow(results)), form)
TiV = cbind(times, results[2])
colnames(TiV) = c("Time in Video", "PULSE")
write_csv(TiV, "!FILEO! - Timed.csv")

time = TiV[nrow(TiV), 1]

PULSEcut = subset(PULSEframe, 65 < PULSEframe$Rate & PULSEframe$Rate < 70)
if (sum(PULSEcut$Count) > 10) {
	PULSEseq <- seq(from = 65, to = max(PULSEclean, 100), by = 1)
} else {
	PULSEseq <- seq(from = 70, to = max(PULSEclean, 100), by = 1)
}

PULSEcut = subset(PULSEframe, 60 < PULSEframe$Rate & PULSEframe$Rate < 65)
if (sum(PULSEcut$Count) > 10) {
PULSEseq <- seq(from = 60, to = max(PULSEclean, 100), by = 1)
} else {}

PULSEquart = quantile(PULSEclean, c(.25, .50, .75))
LABELquart = c("25%", "Median", "75%")

pdf(NULL)

#Graph
ggplot(as.data.frame(PULSEclean), aes(PULSEclean, fill=..count..)) + ggtitle("!FILE!", subtitle=paste("Length - ", time)) + 
scale_fill_gradient("Count", low = "#6d59ff", high = "#ab4b41") + 
geom_vline(xintercept = PULSEquart, size = 2) + 
stat_bin(binwidth = 1, col = "black") + 
scale_x_continuous(breaks = PULSEseq, name = "Heart Rate (bpm)", limits=c(min(PULSEseq) - 1, max(PULSEseq, 101)), minor_breaks = NULL, expand = c(0, 0), sec.axis = sec_axis(trans = ~., breaks = PULSEquart, labels = LABELquart)) + 
scale_y_continuous(name = "Count", expand = c(0.02, 0)) + 
theme_bw(base_size = Tsize) + 
theme(legend.position = c(1, 1), legend.justification = c(1, 1))

if (pdf){
	ggsave(filename="!FILE! - Hist.pdf", device="pdf", width=16, height=9, scale = ggscale)
	} else {
	ggsave(filename="!FILE! - Hist.png", device="png", width=16, height=9, dpi=DPI, scale = ggscale)
	}