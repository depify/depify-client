# Copyright (c) 2011-2014 Jim Fuller  
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0
  
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# depify 0.1, app dep management
#
# see https://github.com/xquery/depify
# see http://depify.com
#
# simple: depify command package version"
#
# advanced: depify [(install|remove|list|info|search) ] [package-name] [package-version]
#
# ex. depify install functional.xq 1.0
#
echo off

set DEPX_HOME=%~dp0

set COMMAND=%1

set PACKAGE=%2

set VERSION=%3
set APP_DIR=%cd:\=/%

echo depify 1.0, app dep management
echo Copyright (c) 2015 Jim Fuller
echo see https://github.com/xquery/depify

echo 
echo command: %COMMAND%
echo package: %PACKAGE%
echo version: %VERSION%
echo app dir: %APP_DIR%
echo 

java -jar $DEPX_DIR\deps\xmlcalabash\calabash.jar -isource=$CURRENTDIR\.depify.xml -oresult=- $DEPX_DIR\libs\xproc\depify.xpl command="$COMMAND" package="$PACKAGE" version=$VERSION app_dir=$APP_DIR app_dir_lib=$LIB_DIR


