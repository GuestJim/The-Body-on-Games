import sys, os

scriptPath = sys.argv[0].rsplit("\\",1)[0]

scriptType = "TBOG"
scriptName = "Pulse"
scriptFull = scriptPath + "\\" + scriptType + " - " + scriptName + ".r"

droppedFile = sys.argv[1]
droppedPath = droppedFile.rsplit("\\",1)[0] + "\\"

droppedName = droppedFile.rsplit("\\",1)[1].split(".")[0]
fileName = droppedName.split('_')[0]

outputName = scriptName + " - " + fileName
outputFull = droppedPath + outputName + ".r"

RPath = droppedPath.replace("\\", "/")

with open(scriptFull, 'r') as fref, open(outputFull, 'w') as fout:
	for line in fref:
		fout.write(line.replace("!PATH!", RPath).replace("!FILE!", fileName).replace("!FILEX!", droppedName + ".csv"))
	fout.close()

#os.system("\"" + outputFull + "\"")
#	runs the script, but not helpful if CSV not editted

os.system("pause")