@echo off

::Laptop
set batloc=C:\Users\Jim\Desktop\FFmpeg Offload

::Desktop
set batloc=E:\Users\Jim\My Videos\FFMPEG Batch files\TBOG


set type=Remux - Archive

start CMD /c call "%batloc%\Remux - Archive - Both.bat" "%~1" "%~2" "%~3"
::	Makes the Archive of the files

start CMD /c call "%batloc%\LoudNorm - Mic.bat" "%~1"
::	Processes the microhpone audio

start CMD /c call "%batloc%\Screenshots - 1 Sec.bat" "%~2"
::	Processes the microhpone audio