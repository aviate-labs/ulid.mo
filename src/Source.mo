import Array "mo:base/Array";
import Binary "mo:encoding/Binary";
import IO "mo:io/IO";
import Result "mo:base/Result";

import Nat80 "Nat80";
import ULID "ULID";
import Time "Time";

module {
    // Returns an entropy source that is guaranteed to yield strictly increasing
	// entropy bytes for the same ULID timestamp. On conflicts, the previous 
	// ULID entropy is incremented with a random number, [1:increment].
	// NOTE: Requires your own entropy source (rand).
    public class Source(
        rand      : IO.Reader<Nat8>,
        increment : Nat64,
    ) {
        public func new() : ULID.ULID {
            let ms = Time.now();
            switch (monotonicRead(ms)) {
				case (#err(e)) {
					// Only on overflows...
					assert(false);
					return [];
				};
				case (#ok(bs)) {
					let t = Time.toArray(ms);
					Array.tabulate<Nat8>(16, func(i : Nat) : Nat8 {
						if (i < 6) return t[i];
						bs[i-6];
					});
				};
			};
        };

        private let inc : Nat64 = if (increment == 0) {
			4_294_967_295; // max u32
		} else { increment };

        // Entropy.
		private var e : Nat80.Nat80 = Nat80.ZERO;
		private var t : Nat64  = 0;

        private func monotonicRead(ms : Time.Milliseconds) : Result.Result<[Nat8], Text> {
			if (not Nat80.isZero(e) and t == ms) {
				return switch (updateInc()) {
					case (#err(e)) { #err(e) };
					case (#ok()) {
						#ok(Nat80.toArray(e));
					};
				};
			};
			t := ms;
            let bs = switch (rand.read(10)) {
                case (#ok(bs))    bs;
                case (#eof(bs))   bs;
                case (#err(_, e)) return #err(e);
            };
			e := Nat80.new(bs);
			#ok(bs);
		};

        private func updateInc() : Result.Result<(), Text> {
			let r = random();
			switch (Nat80.add(e, r)) {
				case (#err(e)) #err(e);
				case (#ok(e_)) {
					e := e_;
					#ok();
				};
			};
		};

        // Returns a random Nat64 in the range [1:inc[.
		private func random() : Nat64 {
			if (inc <= 1) return 1;
			let n = randomNat64n(inc);
			1 + n;
		};

		// Returns a random Nat64 in the range [1:n[.
		private func randomNat64n(n : Nat64) : Nat64 {
			let r = randomNat64();
			if (n & (n - 1) == 0) return r & (n - 1);
			r % n;
		};

		// Returns a random Nat64.
		private func randomNat64() : Nat64 {
            let n = switch (rand.read(8)) {
                case (#ok(bs))    bs;
                case (#eof(bs))   bs;
                case (#err(_, e)) {
                    assert(false);
                    return 0;
                };
            };
			Binary.BigEndian.toNat64(n);
		};
    };
};
