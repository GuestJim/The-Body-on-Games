@echo off
::echo "%~1"

TITLE TBOG Overlay - %~n1

set folder=Overlay

set rateU=7M
set qualityU=-c:v libx264 -crf 18 -maxrate %rateU% -bufsize %rateU% -preset medium

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

ffmpeg -i "%~1" ^
-filter_complex "%command%" %qualityU% ^
-c:a copy -map 0:a:0 -movflags faststart -benchmark "%~dp1%folder%\%~n1 - Upload.mp4"

::pause

::The %~1 is a variable selecting the file dragged onto the batch file.