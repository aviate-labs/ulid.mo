import Array "mo:base/Array";
import Array_ "mo:array/Array";
import Binary "mo:encoding/Binary";
import Blob "mo:base/Blob";
import Int "mo:base/Int";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Random "mo:base/Random";
import Result "mo:base/Result";
import Text "mo:base/Text";
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

	public module ULID = {
		public func toText(id : ULID) : Text {
			switch (Text.decodeUtf8(Blob.fromArray([
				enc[Nat8.toNat((id[0] & 224) >> 5)],
				enc[Nat8.toNat(id[0] & 31)],
				enc[Nat8.toNat((id[1] & 248) >> 3)],
				enc[Nat8.toNat(((id[1] & 7) << 2) | ((id[2] & 192) >> 6))],
				enc[Nat8.toNat((id[2] & 62) >> 1)],
				enc[Nat8.toNat(((id[2] & 1) << 4) | ((id[3] & 240) >> 4))],
				enc[Nat8.toNat(((id[3] & 15) << 1) | ((id[4] & 128) >> 7))],
				enc[Nat8.toNat((id[4] & 124) >> 2)],
				enc[Nat8.toNat(((id[4] & 3) << 3) | ((id[5] & 224) >> 5))],
				enc[Nat8.toNat(id[5] & 31)],

				enc[Nat8.toNat((id[6] & 248) >> 3)],
				enc[Nat8.toNat(((id[6] & 7) << 2) | ((id[7] & 192) >> 6))],
				enc[Nat8.toNat((id[7] & 62) >> 1)],
				enc[Nat8.toNat(((id[7] & 1) << 4) | ((id[8] & 240) >> 4))],
				enc[Nat8.toNat(((id[8] & 15) << 1) | ((id[9] & 128) >> 7))],
				enc[Nat8.toNat((id[9] & 124) >> 2)],
				enc[Nat8.toNat(((id[9] & 3) << 3) | ((id[10] & 224) >> 5))],
				enc[Nat8.toNat(id[10] & 31)],
				enc[Nat8.toNat((id[11] & 248) >> 3)],
				enc[Nat8.toNat(((id[11] & 7) << 2) | ((id[12] & 192) >> 6))],
				enc[Nat8.toNat((id[12] & 62) >> 1)],
				enc[Nat8.toNat(((id[12] & 1) << 4)|((id[13] & 240) >> 4))],
				enc[Nat8.toNat(((id[13] & 15) << 1) | ((id[14] & 128) >> 7))],
				enc[Nat8.toNat((id[14] & 124) >> 2)],
				enc[Nat8.toNat(((id[14] & 3) << 3)|((id[15] & 224) >> 5))],
				enc[Nat8.toNat(id[15] & 31)],
			]))) {
				case (? t)  { t };
				case (null) { assert(false); "" };
			};
		};

		private let enc : [Nat8] = [
			// "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
			48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70, 
			71, 72, 74, 75, 77, 78, 80, 81, 82, 83, 84, 86, 87, 88, 89, 90,
		];
	};

	// Returns an entropy source that is guaranteed to yield strictly increasing
	// entropy bytes for the same ULID timestamp. On conflicts, the previous 
	// ULID entropy is incremented with a random number, [1:increment].
	public class MonotonicEntropy(
		increment : Nat64,
	) {
		// Returns a new raw ULID based on the current time.
		public func new() : async ULID {
			let ms = Nat64.fromNat(Int.abs(Time.now() / 1_000));
			switch (await monotonicRead(ms)) {
				case (#err(e)) {
					// Only on overflows...
					assert(false);
					return [];
				};
				case (#ok(bs)) {
					let t : [Nat8] = [
						byte(ms >> 40),
						byte(ms >> 32),
						byte(ms >> 24),
						byte(ms >> 16),
						byte(ms >> 8),
						byte(ms)
					];
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
		private var e : Nat80  = { low = 0; high = 0 };
		private var t : Nat64  = 0;
		private var r : [Nat8] = [];

		private func monotonicRead(ms : Nat64) : async Result.Result<[Nat8], Text> {
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

		private func byte(n : Nat64) : Nat8 {
			Nat8.fromNat(Nat64.toNat(n & 0xFF));
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
