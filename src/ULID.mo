import Array "mo:base/Array";
import Array_ "mo:array/Array";
import Binary "mo:encoding/Binary";
import Blob "mo:base/Blob";
import Int "mo:base/Int";
import Nat64 "mo:base/Nat64";
import Random "mo:base/Random";
import Result "mo:base/Result";
import Time "mo:base/Time";

module {
    // ULID is a 16 byte Universally Unique Lexicographically Sortable Identifier.
    // Encoded as 16 octets, MSB first.
    //
    //  0                   1                   2                   3
	//  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
	// -----------------------------------------------------------------
	// |                      32_bit_uint_time_high                    |
	// -----------------------------------------------------------------
	// |     16_bit_uint_time_low      |       16_bit_uint_random      |
	// -----------------------------------------------------------------
	// |                       32_bit_uint_random                      |
	// -----------------------------------------------------------------
	// |                       32_bit_uint_random                      |
	// -----------------------------------------------------------------
    public type ULID = [Nat8]; // [u8; 16]

	// Returns an entropy source that is guaranteed to yield strictly increasing
	// entropy bytes for the same ULID timestamp. On conflicts, the previous 
	// ULID entropy is incremented with a random number, [1:increment].
	public class MonotonicEntropy(
		increment : Nat64,
	) {
		private let inc : Nat64 = if (increment == 0) {
			4_294_967_295; // max u32
		} else { increment };

		// Entropy.
		private var e : Nat80  = { low = 0; high = 0 };
		private var t : Nat64  = 0;
		private var r : [Nat8] = [];

		public func monotonicRead() : async Result.Result<[Nat8], Text> {
			let t_ = Nat64.fromNat(Int.abs(Time.now() / 1_000));
			if (not Nat80.isZero(e) and t == t_) {
				return switch (await updateInc()) {
					case (#err(e)) { #err(e) };
					case (#ok()) {
						#ok(Nat80.toArray(e));
					};
				};
			};
			t := t_;
			let bs = await read(6);
			e := Nat80.new(bs);
			#ok(bs);
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
				let (bs, r_) = Array_.split<Nat8>(r, 8);
				r := r_;
				bs;
			};
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
	};

	private type Nat80 = {
		low  : Nat64;
		high : Nat16;
	};

	private module Nat80 {
		public func new(bs : [Nat8]) : Nat80 {
			let (hi, lo) = Array_.split(bs, 2);
			{
				low  = Binary.BigEndian.toNat64(lo);
				high = Binary.BigEndian.toNat16(hi);
			};
		};

		public func toArray(n : Nat80) : [Nat8] {
			Array.append<Nat8>(
				Binary.BigEndian.fromNat16(n.high),
				Binary.BigEndian.fromNat64(n.low),
			);
		};

		public func add(n80 : Nat80, n : Nat64) : Result.Result<Nat80, Text> {
			var l = n80.low +% n;
			var h = n80.high;
			if (n80.low < l) h +%= 1;
			if (n80.high < h) return #err("overflow");
			#ok({ low = l; high = h; });
		};

		public func isZero(n : Nat80) : Bool {
			n.low == 0 and n.high == 0;
		}
	};
};
