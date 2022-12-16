import Array "mo:base-0.7.3/Array";
import Array_ "mo:array/Array";
import Binary "mo:encoding/Binary";
import Result "mo:base-0.7.3/Result";

module {
    public let ZERO : Nat80 = { low = 0; high = 0 };

	public type Nat80 = {
		low  : Nat64;
		high : Nat16;
	};

	public func new(bs : [Nat8]) : Nat80 {
		let (hi, lo) = Array_.split(bs, 2);
		{
			low  = Binary.BigEndian.toNat64(lo);
			high = Binary.BigEndian.toNat16(hi);
		};
	};

	public func toArray(n : Nat80) : [Nat8] {
		let h = Binary.BigEndian.fromNat16(n.high);
		let l = Binary.BigEndian.fromNat64(n.low);
		Array.tabulate<Nat8>(
			10, func (i : Nat) : Nat8 {
				if (i < 2) return h[i];
				l[i - 2];
			}
		);
	};

	public func add(n80 : Nat80, n : Nat64) : Result.Result<Nat80, Text> {
		var l = n80.low +% n;
		var h = n80.high;
		if (n80.low > l) h +%= 1;
		if (n80.high > h) return #err("overflow");
		#ok({ low = l; high = h; });
	};

	public func isZero(n : Nat80) : Bool {
		n.low == 0 and n.high == 0;
	};
};
