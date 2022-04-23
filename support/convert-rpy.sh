#!/bin/bash

set -e
for i in rpy/script-*.rpy; do
	php convert-rpy.php "$i"
done
