import sys, os, fileinput
#	loads different modules for Python

droppedFile = sys.argv[1]
droppedPuls = sys.argv[2]
droppedWave = sys.argv[3]
droppedPath = sys.argv[4]
#	assigns the values of the Batch Parameters passed to the Python script to these variables

scriptPath = os.path.abspath('')
#	gets the path of the Python script, which is the same path for the R source scripts
scriptType = "TBOG"
scriptName = "Overlay Combo"
#	separate Type and Name variables for use with the outputName variable below
scriptFull = scriptPath + "\\" + scriptType + " - " + scriptName + ".r"
#	full path and name of the source R script
outputName = scriptName + " - " + droppedPuls.split('_')[0] + ".r"
#	name of output R script
#		.split('_')[0] splits the droppedPuls string at the underscore and then selects the first sub-string
#		this first sub-string lacks the underscore and timecode of the original name
#	full path and name of output R script

RPath = droppedPath.replace("\\", "/")
#	R needs to use / instead of \ for file paths, hence this conversion

os.chdir(droppedPath)
#	changes the current working directory to where the CSV is

from shutil import copyfile
copyfile(scriptFull, outputFull)
#	copies the source R script to the output R script location and name

with fileinput.FileInput(outputName, inplace=True) as file:
	for line in file:
		print(line.replace("!PATH!", RPath).replace("!FILEPuls!", droppedPuls).replace("!FILEWave!", droppedWave).replace("!FILEPulsX!", droppedPuls + ".csv").replace("!FILEWaveX!", droppedWave + ".csv"), end='')
#	reads the lines of the outpur R script and replaces specific strings with the correct references