#!/bin/zsh

for nreps in 1000 10000 100000 1000000 10000000
do
    echo $nreps
    { time python scripts/jaxspeed.py $nreps map ; } 2>> timings.txt
    sed -i '' '$s/$/ '"${nreps}"' nreps 8 threads map primitive/' timings.txt
    { time python scripts/jaxspeed.py $nreps vmap ; } 2>> timings.txt
    sed -i '' '$s/$/ '"${nreps}"' nreps 8 threads vmap primitive/' timings.txt

    for nthreads in 1 8
    do
        echo $nthreads
        { time julia -t $nthreads scripts/jlspeed.jl $nreps ; } 2>> timings.txt
        sed -i '' '$s/$/ '"${nreps}"' nreps '"${nthreads}"' nthreads/' timings.txt
        { time Rscript scripts/rspeed.R $nreps $nthreads ; } 2>> timings.txt
        sed -i '' '$s/$/ '"${nreps}"' nreps '"${nthreads}"' nthreads/' timings.txt
    done
done
