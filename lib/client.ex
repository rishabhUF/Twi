defmodule Client do
    alias Twi.User
    alias Twi.Server
  
    def init({user,server}) do
      {:ok,{user,server}}
    end

    # --------- FUNCTION DEFINATIONS ----------
    def follow(followed_by,follow) do
        GenServer.cast(follow|>String.to_atom, {:add_following, followed_by|>String.to_atom})
    end

    def add_tweet(username,tweet) do
        ##tweet = IO.gets "Enter the tweet"
        GenServer.cast(username|>String.to_atom, {:add_tweet,tweet})
    end

    def give_list(list) do
        GenServer.call(list|> String.to_atom, :give_list)
    end

    def get_tweets(username) do
        GenServer.call(username|> String.to_atom, :get_tweets)
    end
    
    def send_retweet(username,tweet_text) do
        GenServer.cast(username|> String.to_atom, {:send_retweet,tweet_text})
    end
    
    # ---------- GenServer CallBacks --------------
    def handle_call(:get_tweets, _from, {user,server}) do
        {:reply,{user,server},{user,server}}

    def handle_cast({:send_retweet,tweet_text}, %User{username: username, followers: followers, homepage: homepage, tweets: tweets}= user) do
        retweet_ = 
            case Enum.member?(homepage,tweet_text) do
                false ->
                    IO.puts "Tweet not found !!! bitch"
                    []
                true ->
                    IO.puts "Sending retweets"
                    retweet = "retweet from #{username} "<>tweet_text
                    Enum.each(followers, fn(x) ->
                        GenServer.cast(x,{:add_retweet_to_followers,retweet}) end)
                    [retweet]        
            end
        {:noreply, %User{user | tweets: (tweets ++ retweet_)}}
    end

    def handle_cast({:add_retweet_to_followers,retweet}, %User{homepage: homepage} = user) do
        retweet_ = [retweet]
        {:noreply, %User{user | homepage: (homepage ++ retweet_)}}
    end
    def handle_call(:get_tweets, _from, tweets) do
        {:reply,tweets,tweets}
    end

    def handle_cast({:add_tweet,tweet}, {%User{tweets: tweets, followers: followers, online: online}=user, %Server{hashtags: existing_hashtags}=server}) do
        tweets_= [tweet]
        IO.puts "Tweet is uploaded"
         if(String.contains?tweet,"#") do
             hashtags_ =  Regex.scan(~r/\B#[a-zA-Z0-9_]+/, tweet)|> Enum.concat
             Map.put(existing_hashtags,tweet,hashtags_)
         end
        Enum.each(followers, fn(x) ->
            GenServer.cast(x,{:add_tweet_to_followers,tweet}) 
        end)
        {:noreply, {%User{user | tweets: (tweets ++ tweets_)}, %Server{server | hashtags: existing_hashtags}}}   
    end

    def handle_cast({:add_tweet_to_followers,tweet}, {%User{homepage: homepage}=user,server}) do
        tweets_ = [tweet]
        IO.puts "Tweet added to the followers homepage"
        {:noreply, {%User{user | homepage: (homepage ++ tweets_)},server}}
    end

    def handle_call(:give_list, _from, followers) do
        {:reply,followers,followers}
    end

    def handle_cast({:add_following, to_follow}, {%User{followers: followers}=user,%Server{hashtags: existing_hashtags}=server}) do
        follow_ = 
        case Process.whereis(to_follow) do
            nil -> 
                IO.puts "User invalid"
                []
            _pid ->
                IO.puts "User #{to_follow} is followed"
                [to_follow]    
                
        end
       # IO.puts "User is in list of followed"
        {:noreply, {%User{user | followers: (followers ++ follow_)},server}}
    end
end
