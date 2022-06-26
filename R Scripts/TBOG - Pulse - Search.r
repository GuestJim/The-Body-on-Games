library(readr)
library(ggplot2)

# setwd("")
#	only necessary if running by GUI, so leaving it to be done manually

theme_set(theme_bw(base_size = 16))
DPI			=	120
ggdevice	=	"png"

gWIDTH	=	16
gHEIGH	=	9

simpsplit	=	function(...)	unlist(strsplit(...))
game	=	rev(simpsplit(getwd(), "/"))[1]

prettyNUM	=	function(IN){
	out	=	simpsplit(IN, " ")
	paste0(c(
		out[1:(length(out)-1)],
		as.numeric(out[length(out)])),
		collapse = " "
	)
}

sepCOL	=	function(aggOUT)	{
	matCOL	=	sapply(aggOUT, is.matrix)
	LABS	=	aggOUT[, !matCOL]
	if (length(which(matCOL)) == 1)	LABS	=	aggOUT[!matCOL]
	#	necessary for when there is only one column of GROUP labels
	out	=	cbind(LABS, as.data.frame(aggOUT[, matCOL]))
	return(out)
}

customSave	=	function(name="", plot = last_plot(), fold = "", device=ggdevice, width=gWIDTH, height=gHEIGH, dpi=DPI)	{
	if (fold != "")	name	=	paste0(fold, "/", name)
	if	(device	==	"png"	|	device == "both")	{
		ggsave(filename=paste0(name, ".png"), plot = plot, device="png", width=width, height=height, dpi=dpi)
	}
	if	(device	==	"pdf"	|	device == "both")	{
		ggsave(filename=paste0(name, ".pdf"), plot = plot, device="pdf", width=width, height=height)
	}
}

stats	=	function(x)	{c(
	Mean	=	mean(x),
	Lower	=	quantile(x, 0.25, names	=	FALSE),
	Median	=	median(x),
	Upper	=	quantile(x, 0.75, names	=	FALSE),
	Min		=	min(x),
	Max		=	max(x)
	)
}

csvFIND	=	function(DIRECT = getwd(), PAT = "Edited.csv")	{
	LIST		=	list.files(DIRECT, recursive = TRUE, pattern = PAT)
	LIST		=	LIST[!startsWith(LIST, "@")]
	# LIST.full	=	paste0(DIRECT, "/", LIST)

	return(LIST)
}

CSVs	=	csvFIND()

HRdata	=	data.frame(matrix(nrow = 0, ncol = 3))

for (IND in 1:length(CSVs))	{
	PART	=	simpsplit(CSVs[IND], "/")[1]
	print(PART)
	CSVtimed	=	paste0(PART, "/", PART, " - Timed.csv")
	# PARTpret	=	prettyNUM(PART)
	
	if (file.exists(CSVtimed))	{
		temp		=	read_csv(CSVtimed)
		temp$Part	=	PART
		# temp		=	temp[temp$PULSE != 0, }
		HRdata		=	rbind(HRdata, temp)
		next
	}
	temp		=	read_csv(CSVs[IND])
	temp$SPO2	=	NULL
	temp$Part	=	PART

#	CSV with Time in Video
	times	=	format(seq(ISOdate(1,1,1, 0),	by = "sec",	length.out = nrow(temp)), "%H:%M:%S")
	temp	=	cbind(times, temp)
	colnames(temp)[1]	=	"Time in Video"
	write_csv(temp[, -3], CSVtimed)
	
	HRdata		<<-	rbind(HRdata, temp)
	temp		=	temp[temp$PULSE != 0, ]
	
#	Table
	tempTABL	=	as.data.frame(table(temp$PULSE))
	colnames(tempTABL)	=	c("Rate","Count")
	tempTABL$Rate	=	as.numeric(as.character(tempTABL$Rate))
	write.table(tempTABL, file=paste0(PART, "/", PART, " Frequency.txt"), sep = ",", row.names = FALSE)
	
#	Graph
	temp6570	=	sum(tempTABL[temp$Rate >= 65 & tempTABL$Rate < 70, "Count"])
	temp6065	=	sum(tempTABL[temp$Rate >= 65 & tempTABL$Rate < 70, "Count"])
	
	PULSEseq	=	70:max(temp$PULSE, 100)
	if	(temp6570 > 10)	PULSEseq	=	65:max(temp$PULSE, 100)
	if	(temp6065 > 10)	PULSEseq	=	60:max(temp$PULSE, 100)
	
	tempSUM	=	sepCOL(aggregate(temp$PULSE, list(Part = temp$Part), stats))

	sumLines	=	function(wid = 2)list(
		# geom_vline(data = tempSUM, aes(xintercept = Mean), size = wid),
		geom_vline(data = tempSUM, aes(xintercept = Median), size = wid),
		geom_vline(data = tempSUM, aes(xintercept = Lower), size = wid),
		geom_vline(data = tempSUM, aes(xintercept = Upper), size = wid)
	)
	
	graphHIST	=	function()	{
		ggplot(temp, aes(PULSE, fill=after_stat(count))) + 
		# ggtitle(PARTpret, subtitle=paste0("Length - ", max(temp[, "Time in Video"]))) + 
		ggtitle(prettyNUM(PART), subtitle=paste0("Length - ", max(temp[, "Time in Video"]))) + 
		scale_fill_gradient("Count", low = "#6d59ff", high = "#ab4b41") + 
		sumLines(2) + 
		stat_bin(binwidth = 1, col = "black") + 
		scale_x_continuous(
			breaks			=	PULSEseq,
			name			=	"Heart Rate (bpm)",
			limits			=	c(min(PULSEseq) - 1, max(PULSEseq, 101)),
			minor_breaks	=	NULL,
			expand			=	c(0, 0),
			sec.axis		=	dup_axis(
				name	=	NULL,
				breaks	=	tempSUM[, c("Lower", "Median", "Upper")],
				labels	=	c("25%", "Median", "75%"))
				) + 
		scale_y_continuous(name = "Count", expand = c(0.02, 0)) + 
		theme(legend.position = c(1, 1), legend.justification = c(1, 1))
	}
	customSave(name = paste0(PART, " - Hist"), plot = graphHIST(), fold = PART)
}

HRtime	=	sum(aggregate(list(Time = HRdata[, "Time in Video"]), list(Part = HRdata$Part), max)$Time)
timepad	=	function(timesec) {
	sprintf("%02d", c(timesec %/% 3600, timesec %%3600 %/% 60, round(timesec %% 60)))
}
HRtime	=	paste(timepad(as.numeric(HRtime)), collapse = ":")

if (file.exists(paste0(game, ".csv.bz2")))	{
	HRdataOld	=	read_csv(paste0(game, ".csv.bz2"))
	if (nrow(HRdata)>nrow(HRdataOld))	write_csv(HRdata, paste0(game, ".csv.bz2"))
	rm(HRdataOld)	#get rid of the data read from existing CSV
}	else	{	#to check if combined CSV exists and if it is out of date
	write_csv(HRdata, paste0(game, ".csv.bz2"))
}

HRclean	=	HRdata[HRdata$PULSE != 0, ]
HRsummary	=	sepCOL(aggregate(HRclean$PULSE, list(Part = HRclean$Part), stats))

sumLines	=	function(wid = 2)	{
	list(
	# geom_vline(data = HRsummary, aes(xintercept = Mean), size = wid),
	geom_vline(data = HRsummary, aes(xintercept = Median), size = wid),
	geom_vline(data = HRsummary, aes(xintercept = Lower), size = wid),
	geom_vline(data = HRsummary, aes(xintercept = Upper), size = wid)
	)
}

facetHIST	=	function()	{
	ggplot(HRclean, aes(PULSE, fill=after_stat(ncount), group = Part)) + 
	ggtitle(game, subtitle = paste0("Total Time: ", HRtime)) + 
	scale_fill_gradient("Count", low = "#6d59ff", high = "#ab4b41", labels = NULL) + 
	# sumLines +
	stat_bin(binwidth = 1, col = "black") + 
	scale_x_continuous(name = "Heart Rate (bpm)", minor_breaks = NULL) + 
	scale_y_continuous(name = "Count", expand = c(0.02, 0)) + 
		facet_wrap(vars(Part), scales = "free_y", labeller = labeller(Part = function(IN)	sapply(gsub(paste0(game, " - "), "", IN), prettyNUM)	)) + 
	# facet_wrap(vars(Part), scales = "free_y", labeller = labeller(Part = function(IN)	gsub(paste0(game, " - "), "", IN)	)) + 
	theme(legend.position = "none", plot.title.position = "plot")
}

customSave(name = paste0(game, " - Hist"), plot = facetHIST(), width = 16)

##	see about making it so this one Search script will find all of the CSVs and make the separate Timed, Hist, and table outputs for each. It should be doable, and having some check on if Timed.csv exists, to skip making the graph and such when it is already there. This single-script design might be superior to the current multi-script, at least for simplicity. Also will be a fun exercise to get working.

# for (ind in 1:length(CSVs))	{
	# VAR	=	paste0("CSV", ind)
	# assign(VAR, read_csv(CSVs[ind]))
# }
#	this will assign a separate CSV to separate, generated variables
#	not really needed though as having a single data frame with all of the data, and an identifying column, is all that is really needed
#		remembering that may help to get this working as I want it to, especially as I already achieved that with OCAT - Search - PA.r
