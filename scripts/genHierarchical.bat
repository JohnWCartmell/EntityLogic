@echo off

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:%filenamebase%.xml -xsl:%ELOGICHOME%\src\xslt\ERmodel2.physical.xslt -o:..\temp\%filenamebase%.hierarchical.xml style=h


