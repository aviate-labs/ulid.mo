import Debug "mo:base/Debug";

import ULID "../src/ULID";
import AsyncSource "../src/async/Source";

actor {
    private let e = AsyncSource.Source(0);

    public func new() : async Text {
        let id = await e.new();
        Debug.print(debug_show((id, id.size())));
        ULID.ULID.toText(id);
    };
};
