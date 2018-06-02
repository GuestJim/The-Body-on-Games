@echo off

::Laptop
set batloc=C:\Users\Jim\Desktop\FFmpeg Offload

::Desktop
set batloc=E:\Users\Jim\My Videos\FFMPEG Batch files\TBOG
::	my two computers have files in different locations

start CMD /c call "%batloc%\Remux - Archive - Both.bat" "%~1" "%~2" "%~3"
::	Makes the Archive of the files

start CMD /c call "%batloc%\LoudNorm - Mic.bat" "%~1"
::	Processes the microhpone audio

start CMD /c call "%batloc%\Screenshots - 1 Sec.bat" "%~2"
::	grabs first and last 30 frames fromthe BPM graph to cut ends off CSV data
