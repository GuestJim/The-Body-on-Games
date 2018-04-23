@echo off
::echo "%~1"

::how this works is it converts the video to a specific framerate, and exports images
set frames=30

:start

::the directories should never already exist, so just make them without checking
mkdir "%~dp1Screenshots - Start"
mkdir "%~dp1Screenshots - Stop"

ffmpeg -ss -00:00:00 -i "%~1" -vf fps=1 -vframes %frames% "%~dp1Screenshots - Start\%~n1 - %%4d.jpg" -n

::this works back from the end of the file
ffmpeg -sseof -00:00:%frames% -i "%~1" -vf fps=1 -vframes %frames% "%~dp1Screenshots - Stop\%~n1 - %%4d.jpg" -n

shift

if "%~1"=="" goto end
goto start

::shift moves the %~1 command over, allowing this to iterate through multiple files

:end

::pause

::The %~1 is a variable selecting the file dragged onto the batch file.