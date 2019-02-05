import sys, os
#	loads different modules for Python

scriptPath = sys.argv[0].rsplit("\\",1)[0]
#	gets the path to the Python script, which is the same location as the reference R scripts

scriptType = "TBOG"
#	sets the script type is for TBOG files
scriptName = "Pulse"
#	sets the specific script to be used
scriptFull = scriptPath + "\\" + scriptType + " - " + scriptName + ".r"
#	constructs the complete path to the desired script

droppedFile = sys.argv[1]
#	the complete path of the dropped file
#		will only ever be dropping one file at a time
droppedPath = droppedFile.rsplit("\\",1)[0] + "\\"
#	the directory path to the dropped file
droppedName = droppedFile.rsplit("\\",1)[1].split(".")[0]
#	the name of the dropped file

fileName = droppedName.split('_')[0]
#	the file name of the dropped file without timecode

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
		fout.write(line.replace("!PATH!", RPath).replace("!FILE!", fileName).replace("!FILEX!", droppedName + ".csv"))
#			replaces the !PATH!, !FILE!, and !FILEX! text in the reference file
#				note it is writing to fout, not fref, so the reference file is never changed
	fout.close()
#		closes fout, which finishes the file so it can be used

#os.system("\"" + outputFull + "\"")
#	runs the script, but not helpful if CSV not editted

#os.system("pause")