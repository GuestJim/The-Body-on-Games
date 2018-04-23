@echo off
::echo "%~1"

TITLE TBOG Overlay - %~n1

set folder=Overlay

set rateU=10M
set qualityU=libx264 -crf 18 -maxrate %rateU% -bufsize %rateU% -preset veryslow

::this is so I can change the color of the overlay after the fact
::no change
set hue=0
::blue
::set hue=120
::red
::set hue=-120

::with this I can change the opacity of the overlay after the fact as well
set opac=200

::will place the overlay in the lower right corner
set px=main_w-overlay_w
set py=main_h-overlay_h
set px=0
set py=0

::186 because there is some extra space at the top, beyond the room for the SpO2
set crop=186
::220 with the crop = a scaled height of 360 without cropping
set scale=220

::NohBoard Blue
set color=000064

::SPO2 Black
set color=000000


set command=[0:v:2] colorkey=000000:0.01:0.50 [tobii], ^
[tobii] hue=h=%hue%, lut=a="val*%opac%/256" [tobiicolor], ^
[0:v:0][tobiicolor] overlay=shortest=1 [tobiidone]; ^
 ^
[0:v:1] crop=iw:ih-%crop%:0:%crop%, colorkey=%color%:0.01:0.50 [spo2], ^
[spo2] scale=-1:'min(ih,%scale%):flags=lanczos' [spo2over], ^
[tobiidone][spo2over] overlay=x=%px%:y=%py%:shortest=1, format=pix_fmts=yuvj420p

::for colorkey, the first argument is the color, second is similarity, and third is the blend percentage, so 0 is fully transparent

::[tobiiout] scale=-1:'min(ih,1080):flags=lanczos' [tobiidone]; ^
::removing the scaling speeds things up some

if NOT EXIST "%~dp1%folder%" (
mkdir "%~dp1%folder%"
)

::Prevents overwiting or loss of original.
::By having it within ":start" it will work on multiple directories.
::The %~dp1 in the output flag is necessary. It indicates the drive and path of the file.

ffmpeg -i "%~1" -filter_complex "%command%" ^
-c:v %qualityU% -c:a copy -map 0:a:0 -movflags faststart -benchmark "%~dp1%folder%\%~n1 - Upload.mp4"

::pause

::The %~1 is a variable selecting the file dragged onto the batch file.