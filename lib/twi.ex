defmodule Twi do
  use GenServer
  alias Twi.User
  alias Twi.Server

  def give do
    GenServer.call(Mainserver, :give)
  end

  ### --- CALL BACK FUNCTION RECEIVED FROM THE CLIENT ON SERVER MODULE --- ##


  ## handle call for register
  def handle_cast({:register, %User{username: username, password: password}=user}, %Server{users: users} = server) do
    # IO.puts "Registration called"
    username_ =
    case Enum.member?(users,username) do
      false -> GenServer.start_link(Client,user, name: username)
        # IO.puts("User Account : #{username |> to_string} created ")
        [username]
      true -> 
        # IO.puts("!!! User Account : #{username |> to_string} already exits. Try changing username.")
        []
    end
  {:noreply, %Server{server | users: (users ++ username_)}}
  end

   # 
    # 
    # 
    # 
    # 7 HASHTAGS
  def handle_cast({:add_hashtags,newHashtag,tweet}, %Server{hashtags: existingHashtags} = server) do
  #  IO.puts("Reached Hashtag main")
   case Map.has_key?(existingHashtags,newHashtag) do
       false -> 
        # IO.puts("Reached New Hashtag")
        # IO.inspect existingHashtags
        # IO.inspect newHashtag
        # IO.inspect tweet
        newMap_= Map.put_new(existingHashtags,newHashtag,[tweet])

      true -> 
        # IO.puts("Reached Hashtag old")
        #IO.inspect existingHashtags
        temp = Map.get(existingHashtags,newHashtag)
        IO.inspect temp
        temp_=temp++[tweet]
        newMap_=Map.put(existingHashtags,newHashtag,temp_)
        
    end
    # IO.inspect newMap_
  {:noreply, %Server{server| hashtags: newMap_}}
  end
 

  def handle_call({:login,username,password}, _from, state) do
    reply_ =case Process.whereis(:"#{username}") do
      nil ->
        # IO.puts "Please enter the correct UserName. Username not found in database"
        "Please enter the correct UserName. Username not found in database"
      _ ->
       reply =  GenServer.call(:"#{username}",{:login_client,password})  
    end
    {:reply,reply_,state}
  end

  def handle_call({:logout,username}, _from, state) do
    case Process.whereis(:"#{username}") do
      nil ->
        # IO.puts "Please enter the correct UserName. Username not found in database"
      _ ->
       reply =  GenServer.call(:"#{username}",:logout_client)  
    end
    {:reply,reply,state}
  end

  def handle_call({:find_add_tweet,username,tweet}, _from, state) do
    case Process.whereis(:"#{username}") do
      nil ->
        IO.puts "Please enter the correct UserName. Username not found in database"
      _ ->
        # IO.puts "hello"
       reply =  GenServer.cast(:"#{username}",{:add_tweet,tweet})  
    end
    {:reply,reply,state}
  end

  def handle_call({:follow_user,username,to_follow},_from,state) do
    # IO.puts "Inside follow"
    case Process.whereis(:"#{to_follow}") do
      nil ->
        IO.puts "Please enter the correct UserName. Username not found in database"
      _ ->
        # IO.puts "Genserver call called from server_client"
        reply = GenServer.call(:"#{to_follow}",{:client_follow, username})
    end
    {:reply,reply,state}
  end

  def handle_call({:retweet,username,tweet},_from,state) do
    # IO.puts "Inside Retweet"
    case Process.whereis(:"#{username}") do
      nil ->
        IO.puts "Please enter the correct UserName. Username not found in database"
      _ ->
        # IO.puts "Genserver call called from server_client"
        reply = GenServer.cast(:"#{username}",{:send_retweet, tweet})
    end
    {:reply,reply,state}
  end
 
  # ________________________________________________
  # CLIENT QUERY COMMANDS
  # ________________________________________________

  def handle_call({:fetch_mention,username}, _from, state) do
    case Process.whereis(:"#{username}") do
      nil ->
        IO.puts "Please enter the correct UserName. Username not found in database"
      _ ->
       reply =  GenServer.call(:"#{username}",:get_mention)  
    end
    {:reply,reply,state}
  end

  def handle_call({:fetch_hashtags,hashtag}, _from,  %Server{hashtags: existingHashtags} = server) do

    # case Process.whereis(:"#{username}") do
    #   nil ->
    #     IO.puts "Please enter the correct UserName. Username not found in database"
    #   _ ->
    #    reply =  GenServer.call(:"#{username}",{:get_hashtags,password})  
    # end
    {:reply,existingHashtags,server}
  end

  def handle_call({:fetch_userHomepage,username}, _from, state) do
    case Process.whereis(:"#{username}") do
      nil ->
        IO.puts "Please enter the correct UserName. Username not found in database"
      _ ->
       reply =  GenServer.call(:"#{username}",:get_userHomepage)  
    end
    {:reply,reply,state}
  end


  
end
