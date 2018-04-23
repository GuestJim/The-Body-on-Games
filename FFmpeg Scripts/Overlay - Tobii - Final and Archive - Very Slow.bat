@echo off
::echo "%~1"

TITLE TBOG Overlay - %~n1

set folder=Overlay

set rateU=10M
set rateA=25M

set qualityU=libx264 -crf 18 -maxrate %rateU% -bufsize %rateU% -preset veryslow
set qualityA=libx264 -crf 15 -crf_max 18 -maxrate %rateA% -bufsize %rateA% -preset veryslow
set qualityO=libx264 -crf 0 -preset veryslow
::	cannot actually use two different options like this for video streams in the same file

::this is so I can change the color of the overlay after the fact
::no change
set hue=0
::blue
::set hue=120
::red
::set hue=-120

::with this I can change the opacity of the overlay after the fact as well
set opac=200

set command=^
[0:v:1] colorkey=#000000:0.01:0.50 [tobii];^
[tobii] hue=h=%hue%, lut=a="val*%opac%/256" [tobiihue];^
[0:v:0][tobiihue] overlay=shortest=1 [out];^
[out] format=pix_fmts=yuvj420p

::for colorkey, the first argument is the color, second is similarity, and third is the blend percentage, so 0 is fully transparent

::removing the scale filter
::[out] scale=-1:'min(ih,1080):flags=lanczos', format=pix_fmts=yuvj420p

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
-metadata:s:v:1 title="Tobii" ^
-map 1:a -map 0:a:1 -map 0:a:2 -map 0:a:3 -map 0:a:4 ^
-c:a copy ^
-metadata:s:a:0 title="Mix" ^
-metadata:s:a:1 title="Game Audio" ^
-metadata:s:a:2 title="Game Mic" ^
-metadata:s:a:3 title="Overlay Audio" ^
-metadata:s:a:4 title="Overlay Mic" ^
-benchmark "%~dp1%folder%\%~n1 Final.mkv"

::pause

::The %~1 is a variable selecting the file dragged onto the batch file.