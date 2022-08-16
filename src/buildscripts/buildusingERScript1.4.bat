echo %cd%
call %~dp0\set_path_variables

SET SUBJECTNAMEBASE=EntityLogicMetaModel
CALL %ERSCRIPTv1%/ERmodel_v1.4/scripts/gen_downgrade_to_v1.3.bat %SUBJECTNAMEBASE%.xml

call %ERSCRIPTv1%/ERmodel_v1.4/scripts/set_path_variables

java -jar %SAXON_PATH%\saxon9he.jar -s:..\temp\%SUBJECTNAMEBASE%.xml -xsl:%ERHOME%\xslt\ERmodel2.physical.xslt -o:..\temp\%SUBJECTNAMEBASE%.hierarchical.xml style=hs

java -jar %SAXON_PATH%\saxon9he.jar -s:..\temp\%SUBJECTNAMEBASE%.hierarchical.xml -xsl:%ERHOME%\xslt\ERmodel2.svg.xslt -o:..\docs\%SUBJECTNAMEBASE%.hierarchical.svg filestem=%filenamebase%.hierarchical


echo FINALLY NEED TO GENERATE rng

java -jar %SAXON_PATH%\saxon9he.jar -s:../temp/%SUBJECTNAMEBASE%.hierarchical.xml -xsl:%ERSCRIPTv1%/ERmodel_v1.4/xslt/ERmodel2.rng.xslt -o:../bin/diagram.rng 