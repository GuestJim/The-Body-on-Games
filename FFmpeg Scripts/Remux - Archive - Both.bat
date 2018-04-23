@echo off
::echo "%~1"
TITLE Remux TBOG Archive

::this does work, but I don't know to what end. Just handy. Need to use VLC, but it will play both video streams concurrently and allows the audio streams to be selected.


::this will set the name to be the name of the folder the files are in
for %%* in (.) do set name=%%~nx*
echo %name%

::this third input puts an empty Mix audio track in the spot it will be in the final archive. This allows me to use the same Demux command for both archive types

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

::pause

::The %~1 is a variable selecting the file dragged onto the batch file.
