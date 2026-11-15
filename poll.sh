#!/bin/bash

generator_pid=$1

{
    echo start > start.pipe
    SECONDS=0

    while (( SECONDS < 10 )); do
        ps -eo pid=,ppid=,args=
        sleep 0.1
    done
} | awk -v parent="$generator_pid" '
    NF >= 3 && $3 !~ /^\[/ {
        all[$1] = 1
        if ($2 == parent)
            test[$1] = 1
    }
    END {
        print "PS_ALL  =", length(all)
        print "PS_TEST =", length(test)
    }
'
