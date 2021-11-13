# ULID

Universally Unique Lexicographically Sortable Identifier for the Internet Computer.

## Usage

```motoko
let inc = 123;
let e = ULID.MonotonicEntropy(inc);

let id = await e.new();
ULID.ULID.toText(id);
// "6GNGGRXAKGTXG070DV4GW2JKCJ"
```
