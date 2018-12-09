#!/bin/bash

for i in intermediate/*.svg ; do
    inkscape -d 900 -e out/`basename $i .svg`.png $i
done
