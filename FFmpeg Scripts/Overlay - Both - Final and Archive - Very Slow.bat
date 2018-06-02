@echo off
::echo "%~1"

TITLE TBOG Overlay - %~n1

set folder=Overlay

set rateU=10M
set rateA=25M
::	different maximum bit rates for the Upload version and Archive version

set qualityU=libx264 -crf 18 -maxrate %rateU% -bufsize %rateU% -preset veryslow
set qualityA=libx264 -crf 15 -crf_max 18 -maxrate %rateA% -bufsize %rateA% -preset veryslow
::	the Archive version should always be of beter quality than the upload by using a better CRF and CRF_MAX
::	using VerySlow because filters appeared to bottleneck previously

set qualityO=libx264 -crf 0 -preset veryslow
::	cannot actually use two different options like this for video streams in the Archive file

::this is so I can change the color of the overlay after the fact
::	Gaze overlay is originally green
::no change
set hue=0
::blue
::set hue=120
::red
::set hue=-120

set opac=200
::	with this I can change the opacity of the overlay after the fact as well

set px=main_w-overlay_w
set py=main_h-overlay_h
::set px=0
::set py=0
::	sets the position of the upper left corner of the heart rate monitor

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

::	for colorkey, the first argument is the color, second is similarity, and third is the blend percentage, so 0 is fully transparent
::	it might not be the most efficient, but I prefer to separate the commands for the two different overlays, for easier review

::[tobiiout] scale=-1:'min(ih,1080):flags=lanczos' [tobiidone]; ^
::	for scaling the original video and Gaze overlay. Not currently used

if NOT EXIST "%~dp1%folder%" (
mkdir "%~dp1%folder%"
)

::Prevents overwiting or loss of original.
::By having it within ":start" it will work on multiple directories.
::The %~dp1 in the output flag is necessary. It indicates the drive and path of the file.

ffmpeg -i "%~1" -i "%~2" -filter_complex "%command%" ^
-c:v %qualityU% -map 1:a -c:a copy -movflags faststart -benchmark "%~dp1%folder%\%~n1 - Upload.mp4" ^
-map 0:v ^
-c:v:0 %qualityA% -c:v:1 copy -c:v:2 copy ^
-metadata:s:v:0 title="Game" ^
-metadata:s:v:1 title="SpO2" ^
-metadata:s:v:2 title="Tobii" ^
-map 1:a -map 0:a:1 -map 0:a:2 -map 0:a:3? -map 0:a:4? -map 0:a:5? -map 0:a:6? ^
-c:a copy ^
-metadata:s:a:0 title="Mix" ^
-metadata:s:a:1 title="Game Audio" ^
-metadata:s:a:2 title="Game Mic" ^
-metadata:s:a:3? title="SpO2 Audio" ^
-metadata:s:a:4? title="SpO2 Mic" ^
-metadata:s:a:5? title="Tobii Audio" ^
-metadata:s:a:6? title="Tobii Mic" ^
-benchmark "%~dp1%folder%\%~n1 Final.mkv"
::	this command takes in the Archive file and the editted audio to produce the Upload file and an Archive - Final file that holds all of the streams
::	Archive - Final is smaller and technically lower quality, but helps with the limited amount of storage space I have
::	Archive - Final, by having all of the streams, can then be used to produce the Upload again more easily

::pause

::The %~1 is a variable selecting the file dragged onto the batch file.
