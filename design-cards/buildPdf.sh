#!/bin/bash

for i in intermediate/*.svg ; do
    inkscape -d 300 -A pdf/front/`basename $i .svg`.pdf $i
done

FILES=`ls -f pdf/manual/{1..4}f.pdf pdf/front/*.pdf pdf/manual/5f.pdf`
BACK_FILES=`ls -f pdf/back/{si*,po*,ab*,co*,pr*,id*,ro*,te*,qu*,qu*,ac*,ac*}`
OPTIONS='--nup 2x2 --noautoscale true'

for p in a4 letter ; do
    pdfjam $FILES $OPTIONS --paper $p --outfile pdf/tmp/front_$p.pdf
    pdfjam pdf/manual/{2,1,4,3}b.pdf $OPTIONS --paper $p --outfile pdf/tmp/back1_$p.pdf
    pdfjam $BACK_FILES $OPTIONS --duplicatepages 4 --paper $p --outfile pdf/tmp/back2_$p.pdf
    pdfjam pdf/manual/5b.pdf pdf/back/joker.pdf $OPTIONS --paper $p --outfile pdf/tmp/back3_$p.pdf
    pdfjam \
        pdf/tmp/terms.pdf \
        pdf/tmp/front_$p.pdf  1 pdf/tmp/back1_$p.pdf  1 \
        pdf/tmp/front_$p.pdf  2 pdf/tmp/back2_$p.pdf  1 \
        pdf/tmp/front_$p.pdf  3 pdf/tmp/back2_$p.pdf  2 \
        pdf/tmp/front_$p.pdf  4 pdf/tmp/back2_$p.pdf  3 \
        pdf/tmp/front_$p.pdf  5 pdf/tmp/back2_$p.pdf  4 \
        pdf/tmp/front_$p.pdf  6 pdf/tmp/back2_$p.pdf  5 \
        pdf/tmp/front_$p.pdf  7 pdf/tmp/back2_$p.pdf  6 \
        pdf/tmp/front_$p.pdf  8 pdf/tmp/back2_$p.pdf  7 \
        pdf/tmp/front_$p.pdf  9 pdf/tmp/back2_$p.pdf  8 \
        pdf/tmp/front_$p.pdf 10 pdf/tmp/back2_$p.pdf  9 \
        pdf/tmp/front_$p.pdf 11 pdf/tmp/back2_$p.pdf 10 \
        pdf/tmp/front_$p.pdf 12 pdf/tmp/back2_$p.pdf 11 \
        pdf/tmp/front_$p.pdf 13 pdf/tmp/back2_$p.pdf 12 \
        pdf/tmp/front_$p.pdf 14 pdf/tmp/back3_$p.pdf  1 \
        --noautoscale true --paper $p --outfile pdf/DesignCards_$p.pdf
done

