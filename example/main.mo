import Debug "mo:base/Debug";
import XorShift "mo:rand/XorShift";

import ULID "../src/ULID";
import Source "../src/Source";
import AsyncSource "../src/async/Source";

actor {
    private let ae = AsyncSource.Source(0);

    private let rr = XorShift.toReader(XorShift.XorShift64(null));
    private let se = Source.Source(rr, 0);

    public func newAsync() : async Text {
        let id = await ae.new();
        Debug.print(debug_show((id, id.size())));
        ULID.ULID.toText(id);
    };

    public func newSync() : async Text {
        let id = se.new();
        Debug.print(debug_show((id, id.size())));
        ULID.ULID.toText(id);
    };
};
