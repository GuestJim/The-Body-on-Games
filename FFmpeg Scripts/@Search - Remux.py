import sys, os, shutil

droppedPath = sys.argv[1].rsplit("\\",1)[0] + "\\"

Folds = [x[0] for x in next(os.walk(droppedPath))[1]]
#	gets a list of folders in the dropped directory's parent
Folds = next(os.walk(droppedPath))[1]

for fold in Folds:
	if os.path.isfile(fold):
		Folds.remove(fold)
	if "Assets" in fold:
		Folds.remove(fold)
	if "YouTube Thumbnails" in fold:
		Folds.remove(fold)

# for fold in Folds:
	# print(fold)

# os.system("pause")

for fold in Folds:
	for file in os.listdir(droppedPath + fold):
		if file.endswith("Game.mkv"):
			print(droppedPath + fold + "\\" + file + "\n")
			os.system("python \"@Remux, Audio, Images.py\" \"" + droppedPath + fold + "\\" + file + "\"")

#os.system("pause")

#	make another version for finding the Archive files and doing the processing
#		will need it to detect if the files already exist, either in the Overlay folder or in the main folder (using the os.walk feature may work)
#		don't need to use os.walk, since that folder will always be Overlay, though it might be able to get the list of files there too