library(readr)
library(ggplot2)
setwd("M:/TBOG/Dark Souls 2/Dark Souls 2 - Chapter 1/")
results <- read_csv("Dark Souls 2 - Chapter 1_201804011546 - Edited.csv")

#Variables
PULSEframe <- as.data.frame(table(results$PULSE[!results$PULSE==0]))
PULSEframe = data.frame(as.numeric(as.character(PULSEframe$Var1)),as.numeric(as.character(PULSEframe$Freq)))
colnames(PULSEframe) <- c("Rate","Count")
PULSEclean <- results$PULSE[!results$PULSE==0]

PULSEcut = subset(PULSEframe, 65 < PULSEframe$Rate & PULSEframe$Rate < 70)
if (sum(PULSEcut$Count) > 10) {
  PULSEseq <- seq(from=65, to=max(PULSEclean,100), by=1)
} else {
  PULSEseq <- seq(from=70, to=max(PULSEclean,100), by=1)
}

PULSEcut = subset(PULSEframe, 60 < PULSEframe$Rate & PULSEframe$Rate < 65)
if (sum(PULSEcut$Count) > 10) {
  PULSEseq <- seq(from=60, to=max(PULSEclean,100), by=1)
} else {}

#Process
write.table(PULSEframe,file="Dark Souls 2 - Chapter 1 Frequency.txt", sep=",",row.names=FALSE)
quantile(PULSEclean, c(.001, .01, .99, 0.999))
summary(PULSEclean)

#Time in Video
form = "%H:%M:%S"
times = format(seq(ISOdate(1,1,1, 0), by = "sec", length.out = dim(results)[1]), form)
TiV = cbind(times, results[2])
colnames(TiV) = c("Time in Video ","PULSE")
write_csv(TiV, "Dark Souls 2 - Chapter 1_201804011546 - Timed.csv")

time = TiV[dim(TiV)[1], 1]

pdf(NULL)

#Graph
ggplot(as.data.frame(PULSEclean), aes(PULSEclean, fill=..count..)) + ggtitle("Dark Souls 2 - Chapter 1", subtitle=paste("Length -",time)) + stat_bin(binwidth=1, col="black") + scale_x_continuous(labels=PULSEseq, breaks=PULSEseq, name="Heart Rate (bpm)", limits=c(min(PULSEseq)-1,max(PULSEseq,101)), minor_breaks=NULL, expand=c(0,1)) + scale_y_continuous(name="Count", expand=c(0.02,0)) + scale_fill_gradient("Count", low = "#6d59ff", high = "#ab4b41") + theme_bw()
ggsave(filename="Dark Souls 2 - Chapter 1 - Hist.png", device="png", width=12.8, height=7.2, dpi=150)
#ggsave(filename="Dark Souls 2 - Chapter 1 - Hist.pdf", device="pdf", width=12.8, height=7.2)
