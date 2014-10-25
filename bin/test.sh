#/bin/bash

cd ../test

calabash -i source=test.xprocspec -o result=target/test.xml -o html=target/test.html -o junit=target/test-junit.xml xprocspec/xprocspec/src/main/resources/content/xml/xproc/xprocspec.xpl depify-repo-download-url=packages.xml


