import sys, os

droppedPath = sys.argv[1].rsplit("\\",1)[0] + "\\"

#droppedFiles = sys.argv[1:]
#	works for dropping all relevant files onto it, but below is better
droppedFiles = os.listdir(droppedPath)
#	with this one file dropped from the folder is enough
os.chdir(droppedPath)
#	this is necessary for the resulting file names to be correct

droppedGame = None
droppedTobi = None
droppedSpO2 = None
droppedNDIv = None

droppedNAME = sys.argv[1].rsplit("\\",2)[1] + " - NDI.mkv"

#batloc = "E:\\Users\\Jim\\My Videos\\FFMPEG Batch files\\TBOG"
batcall = "start CMD /c call \"E:\\Users\\Jim\\My Videos\\FFMPEG Batch files\\TBOG"


for file in droppedFiles:
	if "Game" in file:
		droppedGame = file
	if "Tobii" in file:
		droppedTobi = file
	if "SpO2" in file:
		droppedSpO2 = file
	if "NDI" in file:
		droppedNDIv = file

if droppedSpO2 is not None:
	os.system(batcall + "\\Remux - Archive - Both.bat\" \"" + droppedGame + "\" \"" + droppedSpO2 + "\" \"" + droppedTobi + "\"" )
	os.system(batcall + "\\Screenshots - 1 Sec.bat\" \"" + droppedSpO2 + "\"")
else:
	os.system(batcall + "\\Remux - Archive.bat\" \"" + droppedGame + "\" \"" + droppedTobi + "\"" )

if droppedNDIv is not None:
	os.rename(droppedNDIv, droppedNAME)

os.system(batcall + "\\LoudNorm - Mic.bat\" \"" + droppedGame + "\"")

#os.system("pause")