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
    IO.puts "Registration called"
    username_ =
    case Enum.member?(users,username) do
      false -> GenServer.start_link(Client,user, name: username)
        IO.puts("User Account : #{username |> to_string} created ")
        [username]
      true -> 
        IO.puts("!!! User Account : #{username |> to_string} already exits. Try changing username.")
        []
    end
  {:noreply, %Server{server | users: (users ++ username_)}}
  end

  def handle_call({:login,username,password}, _from, state) do
    case Process.whereis(:"#{username}") do
      nil ->
        IO.puts "Please enter the correct UserName. Username not found in database"
      _ ->
       reply =  GenServer.call(:"#{username}",{:login_client,password})  
    end
    {:reply,reply,state}
  end
  ## handle call to print the users
  # def handle_call(:give, _from,users) do
    
  #   {:reply,users,users}
  # end

  
end
