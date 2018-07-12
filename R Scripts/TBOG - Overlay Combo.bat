@echo off

pushd %~dp0

python "TBOG - Overlay Combo.py" "%~1" "%~n1" "%~n2" "%~dp1
::	curiously I cannot close for the path
::	this will open the script and pass it those three arguments
::	these arguments are then passed through as sys.argv which can be called in Python

::spause