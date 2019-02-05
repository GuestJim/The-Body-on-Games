import sys, os
#	loads different modules for Python

scriptPath = sys.argv[0].rsplit("\\",1)[0]
#	gets the path to the Python script, which is the same location as the reference R scripts

scriptType = "TBOG"
#	sets the script type is for TBOG files
scriptName = "Overlay Combo"
#	sets the specific script to be used
scriptFull = scriptPath + "\\" + scriptType + " - " + scriptName + ".r"
#	constructs the complete path to the desired script

droppedFiles = sys.argv[1:]
#	the complete paths to the dropped files
#		2 files must be dropped, as one holds the WAVE data
droppedPath = droppedFiles[0].rsplit("\\",1)[0] + "\\"
#	the directory path to the dropped files

for file in droppedFiles:
#	goes through the list of droppedFiles
	if "_wave" in file:
#		checks if _wave is in the file name
		droppedWave = file.replace("\\", "/")
#			saves the file location to the correct variable
#			replaces the \ symbols with / for R
	else:
#		if it is not the WAVE file, it is the pulse file
		droppedPuls = file.replace("\\", "/")
#			saves the file location to the correct variable
#			replaces the \ symbols with / for R

namePuls = droppedPuls.rsplit("/",1)[1].split(".")[0]
#	the file name for just the pulse file
fileName = namePuls.split('_')[0]
#	the file name of the pulse file without timecode

outputName = scriptName + " - " + fileName
#	constructs the name for the output file
outputFull = droppedPath + outputName + ".r"
#	constructs the complete path for the output file

RPath = droppedPath.replace("\\", "/")
#	R needs to use / instead of \ for file paths, hence this conversion

with open(scriptFull, 'r') as fref, open(outputFull, 'w') as fout:
#	opens and reads the reference R script to the fref variable
#	opens the output R script, and calls it fout
	for line in fref:
#		reads through each line from the reference file
		fout.write(line.replace("!PATH!", RPath).replace("!FILEPuls!", fileName).replace("!FILEWave!", droppedWave).replace("!FILEPulsX!", droppedPuls).replace("!FILEWaveX!", droppedWave))
#			replaces the !PATH!, !FILEPuls!, !FILEPulsX!, etc. text in the reference file
#				note it is writing to fout, not fref, so the reference file is never changed
	fout.close()
#		closes fout, which finishes the file so it can be used

#os.system("\"" + outputFull + "\"")
#	runs the script but not helpful if CSV not editted

#os.system("pause")