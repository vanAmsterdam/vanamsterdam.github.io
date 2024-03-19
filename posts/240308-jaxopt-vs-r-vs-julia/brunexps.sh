#!/bin/bash

for nreps in 1000 10000 100000 1000000 10000000
do
    echo $nreps
    { time python scripts/jaxspeed.py $nreps map; } 2>&1 | grep real >> bashtimings.txt
    sed -i '$s/$/ jax '"${nreps}"' nreps 12 nthreads map primitive/' bashtimings.txt
    { time python scripts/jaxspeed.py $nreps vmap; } 2>&1 | grep real >> bashtimings.txt
    sed -i '$s/$/ jax '"${nreps}"' nreps 12 nthreads vmap primitive/' bashtimings.txt

    for nthreads in 1 6 12
    do
	    echo $nthreads
	    { time julia -t $nthreads scripts/jlspeed.jl $nreps ; } 2>&1 | grep real >> bashtimings.txt
	    sed -i '$s/$/ julia '"${nreps}"' nreps '"${nthreads}"' nthreads/' bashtimings.txt
	    { time Rscript scripts/rspeed.R $nreps $nthreads ; } 2>&1 | grep real >> bashtimings.txt
	    sed -i '$s/$/ r '"${nreps}"' nreps '"${nthreads}"' nthreads/' bashtimings.txt
    done
done
