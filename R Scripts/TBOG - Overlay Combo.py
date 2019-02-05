import sys, os

scriptPath = sys.argv[0].rsplit("\\",1)[0]

scriptType = "TBOG"
scriptName = "Overlay Combo"
scriptFull = scriptPath + "\\" + scriptType + " - " + scriptName + ".r"

droppedFiles = sys.argv[1:]
droppedPath = droppedFiles[0].rsplit("\\",1)[0] + "\\"

for file in droppedFiles:
	if "_wave" in file:
		droppedWave = file.replace("\\", "/")
	else:
		droppedPuls = file.replace("\\", "/")

namePuls = droppedPuls.rsplit("/",1)[1].split(".")[0]
fileName = namePuls.split('_')[0]

outputName = scriptName + " - " + namePuls
outputFull = droppedPath + outputName + ".r"

RPath = droppedPath.replace("\\", "/")

with open(scriptFull, 'r') as fref, open(outputFull, 'w') as fout:
	for line in fref:
		fout.write(line.replace("!PATH!", RPath).replace("!FILEPuls!", fileName).replace("!FILEWave!", droppedWave).replace("!FILEPulsX!", droppedPuls).replace("!FILEWaveX!", droppedWave))
	fout.close()

#os.system("\"" + outputFull + "\"")
#	runs the script but not helpful if CSV not editted

os.system("pause")