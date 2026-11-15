#!/bin/bash

cd "$(dirname "$0")" || exit 1
sudo -v || exit 1
test -p start.pipe || mkfifo start.pipe || exit 1

bash load.sh < start.pipe &
generator_pid=$!
trap 'kill "$generator_pid" 2>/dev/null || true' EXIT

set -o pipefail
sudo bpftrace -c "/bin/bash poll.sh $generator_pid" -e 'tracepoint:sched:sched_process_fork /pid == $1/ { @BPF_TEST = count(); }' "$generator_pid" | tee result.txt || exit 1

wait "$generator_pid"
trap - EXIT
