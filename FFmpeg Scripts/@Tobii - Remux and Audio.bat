@echo off

::Laptop
set batloc=C:\Users\Jim\Desktop\FFmpeg Offload

::Desktop
set batloc=E:\Users\Jim\My Videos\FFMPEG Batch files\TBOG

start CMD /c call "%batloc%\Remux - Archive.bat" "%~1" "%~2"
::	Makes the Archive of the files

start CMD /c call "%batloc%\LoudNorm - Mic.bat" "%~1"
::	Processes the microhpone audio
