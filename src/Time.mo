import Int "mo:base-0.7.3/Int";
import Nat8 "mo:base-0.7.3/Nat8";
import Nat64 "mo:base-0.7.3/Nat64";
import Time "mo:base-0.7.3/Time";

// Time package, but in milliseconds.
module {
    public type Milliseconds = Nat64;

    public func now() : Milliseconds {
        Nat64.fromNat(Int.abs(Time.now() / 1_000));
    };

    public func toArray(ms : Milliseconds) : [Nat8] {
        [
			byte(ms >> 40),
			byte(ms >> 32),
			byte(ms >> 24),
			byte(ms >> 16),
			byte(ms >> 8),
			byte(ms)
		];
    };

    private func byte(n : Nat64) : Nat8 {
		Nat8.fromNat(Nat64.toNat(n & 0xFF));
	};
};