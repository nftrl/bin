#!/bin/bash
# opretmappe.sh
# shellscript til at oprette tom mappestruktur.

function ErrorMessage {
    retval=$1
    shift
    printf "dpop-opretmappe.sh: $@\n"
    exit $retval
}

if ! [ $# -eq 1 ]; then # Test om der er givet mappenavn
    ErrorMessage 1 "Brug som: opretmappe.sh <mappenavn>"
fi

dir="./$1"
if [ -d $dir ]; then # Test om mappen findes i forvejen
    ErrorMessage 2 "Mappen $1 findes allerede."
fi

mkdir -p $dir/{ov/{m,l,f},src,tex/img}

touch $dir/README.txt
touch $dir/tex/opg${1}.tex
if [ -f /home/$HOME/Downloads/${1}.pdf ]; then
    cp /home/nftrl/Downloads/${1}.pdf $dir
fi
