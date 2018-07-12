import sys, os, fileinput
droppedFile = sys.argv[1]
droppedPuls = sys.argv[2]
droppedWave = sys.argv[3]
droppedPath = sys.argv[4]

scriptPath = os.path.abspath('')
scriptType = "TBOG"
scriptName = "Overlay Combo"
scriptFull = scriptPath + "\\" + scriptType + " - " + scriptName + ".r"
outputName = scriptName + " - " + droppedPuls.split('_')[0] + ".r"
outputFull = droppedPath + outputName

RPath = droppedPath.replace("\\", "/")

os.chdir(droppedPath)

from shutil import copyfile
copyfile(scriptFull, outputFull)

with fileinput.FileInput(outputName, inplace=True) as file:
	for line in file:
		print(line.replace("!PATH!", RPath).replace("!FILEPuls!", droppedPuls).replace("!FILEWave!", droppedWave).replace("!FILEPulsX!", droppedPuls + ".csv").replace("!FILEWaveX!", droppedWave + ".csv"), end='')