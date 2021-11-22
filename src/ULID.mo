import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";

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
