#!/usr/bin/env sh

echo "| Starting replica."
dfx start --background --clean > /dev/null 2>&1
dfx deploy --no-wallet > /dev/null 2>&1

dfx -q stop > /dev/null 2>&1
