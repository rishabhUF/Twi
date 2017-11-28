defmodule Twi do
  use GenServer
  alias Twi.User
  alias Twi.Server

  ##take user_name and password from the user and call register function.
  ## start the main server with user and hashtags
  def start_server do
    GenServer.start_link(__MODULE__, %Server{users: [], hashtags: %{}}, name: Mainserver)
  end

  def register(username,password \\"") do
    IO.puts "#{username}"
    user = %User{username: username |> String.to_atom, password: password, online: true}
    GenServer.cast(Mainserver, {:register, user})
  end

  def give do
    GenServer.call(Mainserver, :give)
  end

  def handle_cast({:register, %User{username: username}=user}, %Server{users: users} = server) do
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

  def handle_call(:give, _from,users) do
    {:reply,users,users}
  end

end
