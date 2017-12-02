defmodule Client do
    alias Twi.User
    alias Twi.Server
  
    def init(%User{username: username,password: password}=user) do
      {:ok,user}
    end

    # --------- FUNCTION DEFINATIONS COMPLETED ----------
    # 
    # 
    # 
    # 
    # 1 LOGIN   
    def handle_call({:login_client,password},from,%User{password: stored_password, online: online,cacheHomepage: existingCacheHomepage,homepage: existingHomepage,mentions: existingMentions,cacheMention: existingCacheMention}=user) do

        
        if(password == stored_password) do
            if (online == false) do
                # IO.puts "Valid password"
                # Bringing in cached files the first time that user logs in
                homepage_ = existingHomepage ++ existingCacheHomepage
                mentions_ = existingMentions ++ existingCacheMention
                user_ = %User{user | online: true, homepage: homepage_ , cacheHomepage: [], mentions: mentions_, cacheMention: []}
                {:reply,"Login Successful",user_}
            else
                # IO.puts  
                {:reply,"User Already logged in" ,user}   
            end 
        else
            # IO.puts 
            {:reply,"Invalid password",user}    
        end
    end

    # 
    # 
    # 
    # 
    # 2 TWEET

    def handle_cast({:add_tweet,tweet},%User{tweets: tweets, followers: followers, online: onlineStatus}=user) do
        tweets_= [tweet]
        # IO.puts "Tweet is uploaded"

        # Check if the user is online
        if (onlineStatus==false) do
            # Incase user is offine, dont let him tweet
            IO.puts "User is not logged in. Please login before tweeting"
            {:noreply, user}   
        end

        # In case the user is online find out the mentions and add them to the respective user's mentionlist
        if(String.contains?tweet,"@") do
            mentions_ =  Regex.scan(~r/\B@[a-zA-Z0-9_]+/, tweet)|> Enum.concat
            # IO.inspect mentions_
            Enum.each(mentions_, fn(x) ->
                removeLead_ = String.replace(x,"@","")
               # IO.inspect removeLead_
               GenServer.cast(removeLead_|>String.to_atom,{:add_mentions,tweet}) 
           end)
        end
        
        # In case the user is online find out the mentions and add them to the a central Hashtag map
        if(String.contains?tweet,"#") do
             hashtags_ =  Regex.scan(~r/\B#[a-zA-Z0-9_]+/, tweet)|> Enum.concat
            #  IO.inspect hashtags_
             Enum.each(hashtags_, fn(x) ->
                GenServer.cast(Mainserver,{:add_hashtags,x,tweet}) 
            end)
         end
        # add the tweet to followers homepages, if the user is online
        Enum.each(followers, fn(x) ->
            # IO.puts x
            GenServer.cast(:"#{x}",{:add_tweet_to_followers,tweet}) 
        end)
        {:noreply, %User{user | tweets: (tweets ++ tweets_)}}   
    end

    def handle_cast({:add_tweet_to_followers,tweet}, %User{homepage: existingHomepage, cacheHomepage: existingCacheHomepage,online: onlineStatus}=user) do
        tweets_ = [tweet]
        # Check if the user is online
        case (onlineStatus) do
            false ->
                # In case user is offline, add to cached copy of homepage
                IO.puts "Tweet added to the followers cache homepage"
                {:noreply, %User{user | cacheHomepage: (existingCacheHomepage ++ tweets_)}}
            true->
                  # In case user is online, add to actual homepage
                IO.puts "Tweet added to the followers homepage"
                {:noreply, %User{user | homepage: (existingHomepage ++ tweets_)}}
        end     
    end

    # 
    # 
    # 
    # 
    # 3 RETWEET
    def handle_cast({:send_retweet,tweet_text}, %User{username: username, followers: followers, online: onlineStatus, homepage: homepage, tweets: tweets_}= user) do
        # IO.puts ("Inside client.ex")
        # Check if the user is online
        if (onlineStatus==false) do
            # Incase user is offine, dont let him tweet
            IO.puts "User is not logged in. Please login before retweeting"
            {:noreply, user}   
        end
        # Check if the tweet is present on user's homepage
        retweet_ = 
            case Enum.member?(homepage,tweet_text) do
                false ->
                    # If not, then dont let the user retweet
                    IO.puts "Tweet not found!"
                    []
                true ->
                    # If it is, add a small tag in front of tweet and send it to user's followers and add it to its own tweets
                    # IO.puts "Sending retweets"
                    retweet = "RT from #{username} "<>tweet_text
                    Enum.each(followers, fn(x) ->
                        # IO.inspect retweet
                        GenServer.cast(x|>String.to_atom,{:add_retweet_to_followers,retweet}) end)
                    [retweet]        
            end
        {:noreply, %User{user | tweets: (tweets_ ++ retweet_)}}
    end

    def handle_cast({:add_retweet_to_followers,retweet}, %User{homepage: homepage, cacheHomepage: cacheHomepage, online: onlineStatus } = user) do
        retweet_ = [retweet]
          # Check if the user is online
          case (onlineStatus) do
            false ->
                # In case user is offline, add to cached copy of homepage
                cacheHomepage_ = cacheHomepage ++ retweet_
                # IO.puts "Tweet added to the followers cache homepage"
                {:noreply, %User{user | cacheHomepage: cacheHomepage_}}
            true->
                  # In case user is online, add to actual homepage
                  homepage_ = homepage ++ retweet_
                # IO.puts "Tweet added to the followers homepage"
                {:noreply, %User{user | homepage: homepage_}}
        end     
    end
    # 
    # 
    # 
    # 
    # 4 FOLLOW
    def handle_call({:client_follow, follow},_from,%User{username: username, followers: followers_}=user) do
        # IO.inspect follow 
        if Enum.member?(followers_,follow) do
            {:reply,false,user}
        else
            # IO.puts "User #{follow} is followed"
            follows_ = [follow]
            user_ = %User{user | followers: (followers_ ++ follows_)}
            {:reply,true,user_}  
        end   
                      
    end
    # 
    # 
    # 
    # 
    # 5 MENTIONS

    def handle_cast({:add_mentions,tweet}, %User{mentions: existingMentions, cacheMention: existingCacheMention, online: onlineStatus} = user) do
        # IO.puts("Reached Mentions main")
        case onlineStatus do
            false -> 
                cacheMention_ = [tweet]
                existingCacheMention_ = cacheMention_ ++ existingCacheMention
                user_ = %User{user | cacheMention: existingCacheMention_}
                # IO.inspect user_
                {:noreply,user_}
            true -> 
                mention_ = [tweet]
                existingMentions_ = mention_ ++ existingMentions
                user_ = %User{user | mentions: existingMentions_}
                # IO.inspect user_
                {:noreply,user_}
        end
    end 

    # 
    # 
    # 
    # 
    # 6 LOGOUT   
    def handle_call(:logout_client,from,%User{online: onlineStatus}=user) do
        if (onlineStatus == true) do
            user_ = %User{user | online: false}
            {:reply,"Log out successful",user_}
        else
            {:reply,"User Already logged out",user}   
        end 
                
    end   

     
  # ________________________________________________
  # CLIENT QUERY CALLBACKS
  # ________________________________________________
    # 
    # 
    # 
    # 
    # 1 MENTIONS
  def handle_call(:get_mention,from,%User{online: online,mentions: existingMentions}=user) do
        if (online == true) do
            # IO.puts "Valid password"
            # Sending out the mentions that are present for that user.
            {:reply,existingMentions,user}
        else
            # IO.puts  
            {:reply,"User not logged in" ,user}   
        end 
      
    end

    # 
    # 
    # 
    # 
    # 2 Homepage
    def handle_call(:get_userHomepage,from,%User{online: online,homepage: existingHomepage}=user) do
        if (online == true) do
            # IO.puts "Valid password"
            # Sending out the mentions that are present for that user.
            {:reply,existingHomepage,user}
        else
            # IO.puts   
            {:reply,"User not logged in",user}   
        end 
      
    end


end
