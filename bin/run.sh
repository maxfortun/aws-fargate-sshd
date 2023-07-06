#!/bin/bash -ex

while [ "$PWD" != "/" ] && ! [ -d container ]; do
	cd ..
done

if [ "$PWD" = "/" ]; then
	echo "container not found." >&2
	exit 1
fi

name=$(basename $PWD)

PORT_PREFIX=30
PORTS=()
while read containerPort; do
    [ "$containerPort" = "null" -o "$containerPort" = "" ] && continue
    hostPrefix=$PORT_PREFIX
    hostPort=$hostPrefix$containerPort
    while [ "$hostPrefix" != "" -a "$hostPort" -gt "65535" ]; do
        hostPrefix=${hostPrefix%?}
        hostPort=$hostPrefix$containerPort
    done
    PORTS+=( -p $hostPort:$containerPort )
done < <(docker inspect --format '{{ json .Config.ExposedPorts }}' $name:latest| tr , '\n'|cut -d'"' -f2 | sed 's#/.*$##g' | sort -fu)


docker container rm $name || true
docker run -it --rm --env-file bin/run.env "${PORTS[@]}" --name $name $name:latest "$@"
