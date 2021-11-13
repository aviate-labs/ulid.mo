import Debug "mo:base/Debug";

import ULID "../src/ULID";

actor {
    private let e = ULID.MonotonicEntropy(0);

    public func new() : async Text {
        let id = await e.new();
        Debug.print(debug_show((id, id.size())));
        ULID.ULID.toText(id);
    };
};
