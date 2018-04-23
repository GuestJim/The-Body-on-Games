@echo off
::echo "%~1"

TITLE TBOG Overlay - %~n1

set folder=Overlay

set rateU=7M
set rateA=25M

set qualityU=libx264 -crf 18 -maxrate %rateU% -bufsize %rateU% -preset veryslow
set qualityA=libx264 -crf 15 -crf_max 18 -maxrate %rateA% -bufsize %rateA% -preset veryslow
set qualityO=libx264 -crf 0 -preset veryslow
::	cannot actually use two different options like this for video streams in the same file

::will place the overlay in the lower right corner
set px=main_w-overlay_w
set py=main_h-overlay_h
::set px=0
::set py=0

::186 because there is some extra space at the top, beyond the room for the SpO2
set crop=186
::220 with the crop = a scaled height of 360 without cropping
set scale=220

::NohBoard Blue
set key=#000064

::SPO2 Black
set key=#000000

set command=^
[0:v:1] crop=iw:ih-%crop%:0:%crop%, colorkey=%key%:0.01:0.50 [spo2];^
[spo2] scale=-1:'min(ih,%scale%):flags=lanczos' [spo2scale];^
[0:v:0][spo2scale] overlay=x=%px%:y=%py%, format=pix_fmts=yuvj420p

::for colorkey, the first argument is the color, second is similarity, and third is the blend percentage, so 0 is fully transparent

::removing the scale filter
::[0:v:0] scale=-1:'min(ih,1080):flags=lanczos' [game];^

if NOT EXIST "%~dp1%folder%" (
mkdir "%~dp1%folder%"
)

::Prevents overwiting or loss of original.
::By having it within ":start" it will work on multiple directories.
::The %~dp1 in the output flag is necessary. It indicates the drive and path of the file.

ffmpeg -i "%~1" -i "%~2" ^
-map 0:v -filter_complex "%command%" -c:v %qualityU% ^
-map 1:a -c:a copy -movflags faststart -benchmark "%~dp1%folder%\%~n1 - Upload.mp4" ^
-map 0:v -c:v:0 %qualityA% -c:v:1 copy ^
-metadata:s:v:0 title="Game" ^
-metadata:s:v:1 title="Pulse" ^
-map 1:a -map 0:a:1 -map 0:a:2 -map 0:a:3? -map 0:a:4? ^
-c:a copy ^
-metadata:s:a:0 title="Mix" ^
-metadata:s:a:1 title="Game Audio" ^
-metadata:s:a:2 title="Game Mic" ^
-metadata:s:a:3? title="Overlay Audio" ^
-metadata:s:a:4? title="Overlay Mic" ^
-benchmark "%~dp1%folder%\%~n1 Final.mkv"

::pause

::The %~1 is a variable selecting the file dragged onto the batch file.