import ULID "../src/ULID";

actor {
    private let e = ULID.MonotonicEntropy(0);
};
