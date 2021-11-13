#!/usr/bin/env sh

echo "| Starting replica."
dfx start --background --clean > /dev/null 2>&1
dfx deploy --no-wallet > /dev/null 2>&1

j=0
while [ $j -le 9 ]; do
    echo "| Getting new raw ULID ($j): \c"
    dfx canister --no-wallet call ulid new
    j=$(( j + 1 ))
done

dfx -q stop > /dev/null 2>&1
