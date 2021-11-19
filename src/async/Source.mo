import Array "mo:base/Array";
import Array_ "mo:array/Array";
import Binary "mo:encoding/Binary";
import Blob "mo:base/Blob";
import Random "mo:base/Random";
import Result "mo:base/Result";

import Nat80 "../Nat80";
import ULID "../ULID";
import Time "../Time";

module {
	// Returns an entropy source that is guaranteed to yield strictly increasing
	// entropy bytes for the same ULID timestamp. On conflicts, the previous 
	// ULID entropy is incremented with a random number, [1:increment].
	// NOTE: Uses Random.blob() in the background as entropy source.
	public class Source(
		increment : Nat64,
	) {
		// Returns a new raw ULID based on the current time.
		public func new() : async ULID.ULID {
			let ms = Time.now();
			switch (await monotonicRead(ms)) {
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
		private var r : [Nat8] = [];

		private func monotonicRead(ms : Time.Milliseconds) : async Result.Result<[Nat8], Text> {
			if (not Nat80.isZero(e) and t == ms) {
				return switch (await updateInc()) {
					case (#err(e)) { #err(e) };
					case (#ok()) {
						#ok(Nat80.toArray(e));
					};
				};
			};
			t := ms;
			let bs = await read(10);
			e := Nat80.new(bs);
			#ok(bs);
		};

		private func updateInc() : async Result.Result<(), Text> {
			let r = await random();
			switch (Nat80.add(e, r)) {
				case (#err(e)) #err(e);
				case (#ok(e_)) {
					e := e_;
					#ok();
				};
			};
		};

		// Returns a random Nat64 in the range [1:inc[.
		private func random() : async Nat64 {
			if (inc <= 1) return 1;
			let n = await randomNat64n(inc);
			1 + n;
		};

		// Returns a random Nat64 in the range [1:n[.
		private func randomNat64n(n : Nat64) : async Nat64 {
			let r = await randomNat64();
			if (n & (n - 1) == 0) return r & (n - 1);
			r % n;
		};

		// Returns a random Nat64.
		private func randomNat64() : async Nat64 {
			let n = await read(8);
			Binary.BigEndian.toNat64(n);
		};

		private func read(n : Nat) : async [Nat8] {
			return if (r.size() == n) {
				let b = await Random.blob();
				let bs = r;
				r := Blob.toArray(b);
				bs;
			} else if (r.size() < n) {
				let b = await Random.blob();
				let (bs, r_) = Array_.split<Nat8>(Blob.toArray(b), n);
				r := r_;
				bs;
			} else {
				let (bs, r_) = Array_.split<Nat8>(r, n);
				r := r_;
				bs;
			};
		};
	};
};
