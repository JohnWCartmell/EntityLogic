@echo off

set filename=%1
set filenamebase=%filename:~0,-4%

call %~dp0\set_path_variables

java -jar %SAXON_PATH%\saxon-he-11.4.jar -s:%filenamebase%.xml -xsl:%ELOGICHOME%\src\xslt\test_macro_parser.xslt -o:..\temp\%filenamebase%.testout.xml style=h


