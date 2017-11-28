defmodule Twi.User do
    defstruct username: nil,
              password: nil,
              followers: [],
              tweets: [],
              online: false,
              homepage: []
    end

defmodule Twi.Server do
    defstruct users: nil,
              hashtags: %{} ## map of hashtag -> list[tweet]
    end