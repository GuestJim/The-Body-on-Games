import sys, os, shutil

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
droppedCSVs = None

droppedNAME = sys.argv[1].rsplit("\\",2)[1] + " - NDI.mkv"

#batloc = "E:\\Users\\Jim\\My Videos\\FFMPEG Batch files\\TBOG"
batcall = "start CMD /c call \"E:\\Users\\Jim\\My Videos\\FFMPEG Batch files\\TBOG"
batwait = "call \"E:\\Users\\Jim\\My Videos\\FFMPEG Batch files\\TBOG"
pylcall = "call \"E:\\Users\\Jim\\My Videos\\FFMPEG Batch files\\TBOG"

for file in droppedFiles:
	if "Game" in file:
		droppedGame = file
	if "Tobii" in file:
		droppedTobi = file
	if "SpO2" in file:
		droppedSpO2 = file
	if "NDI" in file:
		droppedNDIv = file
	if file.endswith(".csv") and "Edited" not in file and "Timed" not in file:
		droppedCSVs = file
		droppedCSVe = droppedCSVs.split(".csv")[0] + " - Edited.csv"

if droppedCSVs is not None:
	if not os.path.exists(droppedCSVe):
		shutil.copyfile(droppedCSVs, droppedCSVe)
	os.system(pylcall + "\\TBOG - Pulse.py.lnk\" \"" + droppedPath + droppedCSVe + "\"")
#		technically works to run the TBOG - Pulse script, but it breaks because it needs directory path information to be passed to it, and this does not do that

if droppedSpO2 is not None:
	os.system(batcall + "\\Remux - Archive - Both.bat\" \"" + droppedGame + "\" \"" + droppedSpO2 + "\" \"" + droppedTobi + "\"" )
	os.system(batcall + "\\Screenshots - 1 Sec.bat\" \"" + droppedSpO2 + "\"")
else:
	os.system(batcall + "\\Remux - Archive.bat\" \"" + droppedGame + "\" \"" + droppedTobi + "\"" )

if droppedNDIv is not None:
	os.rename(droppedNDIv, droppedNAME)

os.system(batwait + "\\LoudNorm - Mic.bat\" \"" + droppedGame + "\"")
#	by using batwait, this comand will be run in the Python shell, and so Python will wait until it finishes before moving on

#os.system("pause")