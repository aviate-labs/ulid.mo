import Array "mo:base/Array";
import Int "mo:base/Int";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
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
};
