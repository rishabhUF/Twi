defmodule Client do
    alias Twi.User
  
    def init(user) do
      {:ok,user}
    end

    # --------- FUNCTION DEFINATIONS ----------
    def follow(followed_by,follow) do
        GenServer.cast(followed_by, {:add_following, follow})
    end

    def add_tweet(username) do
        tweet = IO.gets "Enter the tweet"
        GenServer.cast(username|>String.to_atom, {:add_tweet,tweet})
    end

    def give_list(list) do
        GenServer.call(list|> String.to_atom, :give_list)
    end

    def get_tweets(username) do
        GenServer.call(username|> String.to_atom, :get_tweets)
    end
    
    
    # ---------- GenServer CallBacks --------------
    def handle_call(:get_tweets, _from, tweets) do
        {:reply,tweets,tweets}
    end

    def handle_cast({:add_tweet,tweet}, %User{tweets: tweets, followers: followers}=user) do
        tweets_= [tweet]
        IO.puts "Tweet is uploaded"
        Enum.each(followers, fn(x) ->
            GenServer.cast(x,{:add_tweet_to_followers,tweet}) 
        end)
        {:noreply, %User{user | tweets: (tweets ++ tweets_)}}   
    end

    def handle_cast({:add_tweet_to_followers,tweet}, %User{tweets: tweets}=user) do
        tweets_ = [tweet]
        IO.puts "Tweet added to the followers"
        {:noreply, %User{user | tweets: (tweets ++ tweets_)}}
    end

    def handle_call(:give_list, _from, followers) do
        {:reply,followers,followers}
    end

    def handle_cast({:add_following, to_follow}, %User{followers: followers}=user) do
        follow_ = 
        case Process.whereis(to_follow) do
            nil -> 
                IO.puts "User invalid"
                []
            _pid ->
                IO.puts "User #{to_follow} is followed"
                [to_follow]    
        end
        {:noreply, %User{user | followers: (followers ++ follow_)}}
    end
end
