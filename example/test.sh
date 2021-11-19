#!/usr/bin/env sh

echo "| Starting replica."
dfx start --background --clean > /dev/null 2>&1
dfx deploy --no-wallet > /dev/null 2>&1

j=0
while [ $j -le 4 ]; do
    echo "| Getting new raw (async) ULID ($j): \c"
    dfx canister --no-wallet call ulid newAsync
    echo "| Getting new raw (sync) ULID ($j):  \c"
    dfx canister --no-wallet call ulid newSync
    j=$(( j + 1 ))
done

dfx -q stop > /dev/null 2>&1
