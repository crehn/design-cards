#!/bin/bash

for i in intermediate/*.svg ; do
    inkscape -d 600 -e out/`basename $i .svg`.png $i
done
