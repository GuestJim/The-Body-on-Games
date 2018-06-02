@echo off
::echo "%~1"
TITLE Remux TBOG Archive

for %%* in (.) do set name=%%~nx*
echo %name%
::	this will set the name to be the name of the folder the files are in

::	this third input puts an empty Mix audio track in the spot it will be in the final archive. This allows me to use the same Demux command for both archive types

ffmpeg -i "%~1" -i "%~2" -i "%~3" -f lavfi -i anullsrc=cl=stereo:r=44100 -shortest -c copy ^
-map 0:v -map 1:v -map 2:v -map 3:a -map 0:a:1 -map 0:a:2 -map 1:a:1? -map 1:a:2? -map 2:a:1? -map 2:a:2? ^
-metadata:s:v:0 title="Game" ^
-metadata:s:v:1 title="Pulse" ^
-metadata:s:v:2 title="Tobii" ^
-metadata:s:a:0 title="Mix" ^
-metadata:s:a:1 title="Game Audio" ^
-metadata:s:a:2 title="Game Mic" ^
-metadata:s:a:3? title="Pulse Game" ^
-metadata:s:a:4? title="Pulse Mic" ^
-metadata:s:a:5? title="Tobii Game" ^
-metadata:s:a:6? title="Tobii Mic" "%name% - Archive.mkv"
::	puts all of the streams into a single file, for easier access, and labels them accordingly
::	the anullsrc is used to produce a place holder audio stream, so the same Demux command can be used with this and Archive - Final files

::pause

::The %~1 is a variable selecting the file dragged onto the batch file.
