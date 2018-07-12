@echo off
::	keeps the console window clean by suppressing the input commands

pushd %~dp0
::	pushes the working directory

python "TBOG - Overlay Pulse.py" "%~1" "%~n1" "%~dp1
::	curiously I cannot close for the path
::	this will open the script and pass it those three arguments
::	these arguments are then passed through as sys.argv which can be called in Python

::pause