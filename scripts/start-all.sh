#!/bin/bash

cdir=`cd $(dirname $0); pwd`;

export HOMEDIR=$cdir/..

function refresh_image_if_necessary() {
    
    md5bin=`which md5`
    if [ x"$md5bin" = x ]; then md5bin=`which md5sum`; fi; 
    
    for n in fluentd sandbox; do 
        echo generating image: $n; 

        dockerfile_path=$HOMEDIR/docker/$n/Dockerfile
        md5_file=$HOMEDIR/docker/.$n.image.md5
        curmd5=`$md5bin -q $dockerfile_path`
        image_name=zongzw/$n:latest
        image_found=`docker images --format "{{.Repository}}:{{.Tag}}" | grep $image_name`

        if [ ! -f $md5_file \
            -o "`cat $md5_file`" != "$curmd5" \
            -o x"$image_found" = x ]; then
            docker build -t $image_name $(dirname $dockerfile_path);
            $md5bin -q $dockerfile_path > $md5_file;
        fi
    done
    
}

refresh_image_if_necessary

docker-compose -f $HOMEDIR/scripts/docker-compose.yml up -d --force-recreate --remove-orphans
