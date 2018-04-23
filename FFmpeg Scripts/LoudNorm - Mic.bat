@echo off
::echo "%~1"

for %%* in (.) do set name=%%~nx*
TITLE LoudNorm - %name%

:start

::Prevents overwiting or loss of original.
::By having it within ":start" it will work on multiple directories.
::The %~dp1 in the output flag is necessary. It indicates the drive and path of the file.

::The loudnorm filter is meant to normalize the loudness, not the amplitude of the audio, so it will all sound similiar, instead of the peak being only so high
::https://www.ffmpeg.org/ffmpeg-all.html#loudnorm
::http://k.ylo.ph/2016/04/04/loudnorm.html

::levels at lower gain amount
set levellow=-55
set levelhigh=-52
::using higher gain now, since the noise of the interface is not amplified with the gain
set levellow=-45
set levelhigh=-40
set amp=-15

set command= ^
[0:a:2] compand=0.01:0.20:-900/-900 %levellow%.1/-900 %levellow%/%levellow% %levelhigh%/%amp%:.01:0:-50:.1, ^
loudnorm=I=-19:LRA=15.0:TP=-2.0 [normout]

::the spaces make them lists for left and right channel
::attack time
::decay time
::points, essentially drawing a graph of what dB levels should be altered, with the first in a pair being the input and second the output
::	-900/-900 -50.1/-900 means everything below -50.1 dB is dropped to -900
::https://ffmpeg.org/ffmpeg-filters.html#compand

ffmpeg -i "%~1" -map 0:a:1 -c:a copy ^
-filter_complex "%command%" ^
-map "[normout]" -c:a:1 flac -ac 1 -compression_level 0 -ar 44100 -sample_fmt s16 ^
-map 0:a:2 ^
-metadata:s:a:0 title="Game" ^
-metadata:s:a:1 title="Mic - LoudNorm" ^
-metadata:s:a:2 title="Mic" ^
-id3v2_version 3 -vn "%~dp1\%name% - Audio.mka" -y

::compression can go between 0 and 8, with 8 being the greatest compression
::there is no difference in quality between compression level, just file size and the speed, but flac is still fast

shift

if "%~1"=="" goto end
goto start

::shift moves the %~1 command over, allowing this to iterate through multiple files

:end

::pause