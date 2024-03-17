#!/bin/bash

for nreps in 1000 10000 100000 1000000 10000000
do
    echo $nreps
    #echo "nreps $nreps" >> bashtimings.txt
    { time julia scripts/jlspeed.jl $nreps ; } 2>&1 | grep real >> bashtimings.txt
    sed -i '$s/$/ julia '"${nreps}"' nreps 1 nthreads/' bashtimings.txt
    { time python scripts/jaxspeed.py $nreps ; } 2>&1 | grep real >> bashtimings.txt
    sed -i '$s/$/ jax '"${nreps}"' nreps 12 nthreads/' bashtimings.txt
    { time Rscript scripts/rspeed.R $nreps ; } 2>&1 | grep real >> bashtimings.txt
    sed -i '$s/$/ r '"${nreps}"' nreps 1 nthreads/' bashtimings.txt

    for nthreads in 6 12
    do
        echo $nthreads
        #echo "nthreads $nthreads" >> timings.txt
	{ time julia -t $nthreads scripts/jlspeed.jl $nreps ; } 2>&1 | grep real >> bashtimings.txt
	sed -i '$s/$/ julia '"${nreps}"' nreps '"${nthreads}"' nthreads/' bashtimings.txt
	{ time Rscript scripts/rspeed.R $nreps $nthreads ; } 2>&1 | grep real >> bashtimings.txt
	sed -i '$s/$/ r '"${nreps}"' nreps '"${nthreads}"' nthreads/' bashtimings.txt
    done
done
