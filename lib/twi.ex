defmodule Twi do
  use GenServer
  alias Twi.User
  alias Twi.Server

  def give do
    GenServer.call(Mainserver, :give)
  end

  ### --- CALL BACK FUNCTION RECEIVED FROM THE CLIENT ON SERVER MODULE --- ##


  ## handle call for register
  def handle_cast({:register, %User{username: username}=user}, %Server{users: users} = server) do
    IO.puts "jjjjjjj"
    username_ =
    case Enum.member?(users,username) do
      false -> GenServer.start_link(Client,{user,server}, name: username)
        IO.puts("User Account : #{username |> to_string} created ")
        [username]
      true -> 
        IO.puts("!!! User Account : #{username |> to_string} already exits. Try changing username.")
        []
    end
  {:noreply, %Server{server | users: (users ++ username_)}}
  end

  ## handle call to print the users
  # def handle_call(:give, _from,users) do
    
  #   {:reply,users,users}
  # end

  def handle_call(:test_function,from,user) do
    IO.puts "here in test function from twitter client"
    {:reply, true,user}
  end

  
end
