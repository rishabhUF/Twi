defmodule Twi.User do
    defstruct username: nil,
              password: nil,
              followers: [],
              tweets: [],
              online: false,
              cacheHomepage: [],
              homepage: [],
              mentions: [],
              cacheMention: []
    end 

defmodule Twi.Server do
    defstruct users: nil,
              hashtags: %{} ## map of hashtag -> list[tweet]
    end
   


# defmodule Twi.Tweet do
#     defstruct tweet_id: nil,
#               tweet_text: nil,
#               original_username: nil,
#               hashtags_added: [],
#               user_mentions_added: []
# end    
