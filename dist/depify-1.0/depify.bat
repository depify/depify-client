echo off


set DEPX_HOME=%~dp0

set COMMAND=%1

set PACKAGE=%2

set VERSION=%3
set APP_DIR=%cd:\=/%
echo depx 0.1, app dep management

echo Copyright (c) 2011, 2012 Jim Fuller

echo see https://github.com/xquery/depx

echo 
echo command: %COMMAND%

echo package: %PACKAGE%

echo version: %VERSION%

echo app dir: %APP_DIR%

echo 

echo depx processing ...


java -Xmx1024m -jar "%DEPX_HOME%deps\xmlcalabash\calabash.jar" -D %DEPX_HOME%libs\xproc\depify.xpl "command=%COMMAND%" "package=%PACKAGE%" "version=%VERSION%" "app_dir=file:///%APP_DIR%"

###java -jar $DEPX_DIR\deps\xmlcalabash\calabash.jar -isource=$CURRENTDIR\depify.xml -oresult=- $DEPX_DIR\libs\xproc\depify.xpl command="$COMMAND" package="$PACKAGE" version=$VERSION app_dir=$APP_DIR app_dir_lib=$LIB_DIR


echo depx processing done

