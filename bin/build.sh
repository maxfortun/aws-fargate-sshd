#!/bin/bash -ex

while [ "$PWD" != "/" ] && ! [ -d container ]; do
	cd ..
done

if [ "$PWD" = "/" ]; then
	echo "container not found." >&2
	exit 1
fi

name=$(basename $PWD)

docker build -t $name container
