import Debug "mo:base/Debug";
import ULID "mo:ulid/ULID";
import Source "mo:ulid/Source";
import AsyncSource "mo:ulid/async/Source";
import XorShift "mo:rand/XorShift";

actor {
    private let ae = AsyncSource.Source(0);

    private let rr = XorShift.toReader(XorShift.XorShift64(null));
    private let se = Source.Source(rr, 0);

    public func newAsync() : async Text {
        let id = await ae.new();
        Debug.print(debug_show((id, id.size())));
        ULID.toText(id);
    };

    public func newSync() : async Text {
        let id = se.new();
        Debug.print(debug_show((id, id.size())));
        ULID.toText(id);
    };
};
