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

## ICDevs.org

This library was incentivized by https://ICDevs.org.  You can view more about the bounty at https://forum.dfinity.org/t/icdevs-org-bounty-3-ulid-motoko-library/8473 and https://icdevs.org/bounties/2021/11/08/ULID-motoko-library.html.  The bounty was funded by The Dragginz Team and the award was graciously donated by di-wu to the treasury of ICDevs.org so that we could pursue more bounties.  If you use this library and gain value from it, please consider a donation to ICDevs at https://icdevs.org/donations.html.
