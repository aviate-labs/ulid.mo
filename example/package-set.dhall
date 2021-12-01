let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.6.7-20210818/package-set.dhall sha256:c4bd3b9ffaf6b48d21841545306d9f69b57e79ce3b1ac5e1f63b068ca4f89957
let aviate-labs = https://github.com/aviate-labs/package-set/releases/download/v0.1.2/package-set.dhall sha256:770d9d2bd9752457319e8018fdcef2813073e76e0637b1f37a7f761e36e1dbc2

let Package = { name : Text, version : Text, repo : Text, dependencies : List Text }
let additions = [
  { name = "io"
  , repo = "https://github.com/aviate-labs/io.mo"
  , version = "v0.3.0"
  , dependencies = [ "base" ]
  },
  { name = "rand"
  , repo = "https://github.com/aviate-labs/rand.mo"
  , version = "v0.2.1"
  , dependencies = [ "base" ]
  },
  { name = "ulid"
  , version = "a1737d9bf1690f58fe2c60b23a844867474e41c4"
  , repo = "https://github.com/aviate-labs/ulid.mo"
  , dependencies = [ "base", "encoding", "io" ]
  },
] : List Package

in  upstream # aviate-labs # additions
