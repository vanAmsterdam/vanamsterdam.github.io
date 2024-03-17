#!/bin/zsh

#for nreps in 1000 100000
#for nreps in 10000000
#for nreps in 10000 1000000
for nreps in 1000 10000 100000 1000000 10000000
do
    echo $nreps
    #echo "nreps $nreps" >> timings.txt
    { time julia scripts/jlspeed.jl $nreps ; } 2>> timings.txt
    sed -i '' '$s/$/ '"${nreps}"' nreps /' timings.txt
    { time python scripts/jaxspeed.py $nreps ; } 2>> timings.txt
    sed -i '' '$s/$/ '"${nreps}"' nreps /' timings.txt
    { time Rscript scripts/rspeed.R $nreps ; } 2>> timings.txt
    sed -i '' '$s/$/ '"${nreps}"' nreps /' timings.txt

    for nthreads in 8
    do
        echo $nthreads
        #echo "nthreads $nthreads" >> timings.txt
        { time julia -t $nthreads scripts/jlspeed.jl $nreps ; } 2>> timings.txt
        sed -i '' '$s/$/ '"${nreps}"' nreps '"${nthreads}"' nthreads/' timings.txt
        { time Rscript scripts/rspeed.R $nreps $nthreads ; } 2>> timings.txt
        sed -i '' '$s/$/ '"${nreps}"' nreps '"${nthreads}"' nthreads/' timings.txt
    done
done
