@echo off
::echo "%~1"

TITLE TBOG Overlay - %~n1

set folder=Overlay

set rateU=7M
set qualityU=-c:v libx264 -crf 18 -maxrate %rateU% -bufsize %rateU% -preset medium

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

ffmpeg -i "%~1" ^
-filter_complex "%command%" %qualityU% ^
-c:a copy -map 0:a:0 -movflags faststart -benchmark "%~dp1%folder%\%~n1 - Upload.mp4"

::pause

::The %~1 is a variable selecting the file dragged onto the batch file.