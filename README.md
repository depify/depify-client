depify-client
=============

[![Build Status](https://travis-ci.org/depify/depify-client.svg)](https://travis-ci.org/depify/depify-client)

XProc dependency management. Download [latest release](https://github.com/depify/depify-client/releases/latest).

install package
```
depify install xprocdoc
```

remove package
```
depify remove xprocdoc
```

info package
```
depify info xprocdoc
```

list installed packages
```
depify list
```

search all packages
```
depify search xproc
```

reinstall all packages
```
depify install
```

generate xproc run script (experimental)
```
depify xproc
```

generate xmlresolver catalogy (experimental)
```
depify catalog
```

generate xproc libraryy (experimental)
```
depify library
```

initialize .depify (experimental)
```
depify init mypackage 1.0
```

[Browse packages](http://depify.com)

## Using a package

Import package as per normal (p:import) 

Alternately you may generate a catalog.xml (depify catalog) though this depends on if the package author provided a catalog definition (example in [xprocdoc](https://github.com/depify/depify-packages/blob/master/packages/master/xproc/1/xprocdoc/1.0/.depify.xml)). 

## Contribute a package

You can [submit your own package](https://github.com/depify/depify-packages/tree/master/packages).

## Running manually

still testing windows shellscript, so ... for those on windoze ...

```
java -jar $DEPIFY_DIR/deps/xmlcalabash/calabash.jar -isource=$CURRENTDIR/.depify.xml -oresult=- $DEPIFY_DIR/libs/xproc/depify.xpl command="$COMMAND" package="$PACKAGE" version=$VERSION app_dir=$APP_DIR app_dir_lib=$LIB_DIR
```

* $COMMAND = install|remove|info|list|search|catalog
* $PACKAGE = package name
* $VERSION = package version
* $APP_DIR = application directory
* $LIB_DIR = dir where packages are stored, under application dir (ex. lib) 

or review [script](https://github.com/depify/depify-client/blob/master/src/client/commandline/depify)

## useful links

[submit](https://github.com/depify/depify-packages/tree/master/packages) a package to the master repo.

[browse](http://depify.com) packages. 

[download](https://github.com/depify/depify-client) depify client.
