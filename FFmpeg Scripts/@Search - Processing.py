import sys, os

droppedPath = sys.argv[1].rsplit("\\",1)[0] + "\\"

for file in os.listdir(droppedPath):
	if "Overlay" in file and "Final and Archive" in file and file.endswith(".bat"):
		batfile = droppedPath + file
#	finds the desired BATCH file

Folds = [x[0] for x in next(os.walk(droppedPath))[1]]
#	gets a list of folders in the dropped directory's parent
Folds = next(os.walk(droppedPath))[1]

# test = [x[0] for x in os.walk(droppedPath)]
	# gets all folders

for fold in Folds:
	if os.path.isfile(fold):
		Folds.remove(fold)
	if "Assets" in fold:
		Folds.remove(fold)
	if "YouTube Thumbnails" in fold:
		Folds.remove(fold)

for fold in Folds:
	TBOGArch = None
	TBOGAudi = None
	foldPath = droppedPath + fold + "\\"
	if not os.path.exists(foldPath + "Overlay"):
		for file in os.listdir(foldPath):
			if file.endswith("Archive Final.mkv") or file.endswith("Upload.mp4"):
				break
			if file.endswith("Archive.mkv"):
				TBOGArch = file
			if file.endswith("Audio.m4a"):
				TBOGAudi = file

			if TBOGArch is not None and TBOGAudi is not None:
				os.chdir(foldPath)
				os.system("call \"" + batfile + "\" \"" + TBOGArch + "\" \"" + TBOGAudi + "\"")
				if TBOGArch.replace(".mkv", " - Upload.mp4") in os.listdir("Overlay"):
					os.rename("Overlay\\" + TBOGArch.replace(".mkv", " - Upload.mp4"), "Overlay\\" + TBOGArch.replace(".mkv", ".mp4").replace(" - Archive", " - Upload"))
				#	having it rename here could be convenient
				for file in os.listdir("Overlay"):
					os.rename("Overlay\\" + file, file)
				os.rmdir("Overlay")
				#	moves the files out of the Overlay folder and then removes the folder
				break

# os.system("pause")
