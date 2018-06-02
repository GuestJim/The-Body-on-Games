@echo off
::echo "%~1"

::this will set the name to be the name of the folder the files are in
for %%* in (.) do set name=%%~nx*
TITLE Remux TBOG Archive - %name%
echo %name%

::this third input puts an empty Mix audio track in the spot it will be in the final archive. This allows me to use the same Demux command for both archive types

ffmpeg -i "%~1" -i "%~2" -f lavfi -i anullsrc=cl=stereo:r=44100 -shortest -c copy ^
-map 0:v -map 1:v -map 2:a -map 0:a:1 -map 0:a:2 -map 1:a:1? -map 1:a:2? ^
-c:a:0 aac -q:a 2 ^
-metadata:s:v:0 title="Game" ^
-metadata:s:v:1 title="Overlay" ^
-metadata:s:a:0 title="Mix" ^
-metadata:s:a:1 title="Game Audio" ^
-metadata:s:a:2 title="Game Mic" ^
-metadata:s:a:3? title="Overlay Game" ^
-metadata:s:a:4? title="Overlay Mic" "%name% - Archive.mkv"
::	this file produces a generic Archive with just Overlay stream labels, for when I was still doing just one overlay and not both

::pause

::The %~1 is a variable selecting the file dragged onto the batch file.
