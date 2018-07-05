import sys, os, fileinput
droppedFile = sys.argv[1]
droppedName = sys.argv[2]
droppedPath = sys.argv[3]

scriptPath = os.path.abspath('')
scriptType = "TBOG"
scriptName = "Pulse"
scriptFull = scriptPath + "\\" + scriptType + " - " + scriptName + ".r"
fileName = droppedName.split('_')[0]
outputName = scriptName + " - " + droppedName + ".r"
outputFull = droppedPath + outputName

RPath = droppedPath.replace("\\", "/")

os.chdir(droppedPath)

from shutil import copyfile
copyfile(scriptFull, outputFull)

with fileinput.FileInput(outputName, inplace=True) as file:
	for line in file:
		print(line.replace("!PATH!", RPath).replace("!FILE!", fileName).replace("!FILEO!", droppedName[:-9]).replace("!FILEX!", droppedName + ".csv"), end='')