defmodule Main do
    use GenServer
    alias Twi.User
    alias Twi.Server

    #### connect to the client module
    def main(args \\ []) do
        ip = get_client_ip_address()
        IO.inspect ip
        # IO.puts "ip fetched"
        Node.start(:"rishabh@#{ip}")
        Node.set_cookie(:"rishabh@#{ip}",:"twiserver")
        # IO.puts "node chal gai"
        {:ok,pid}=GenServer.start_link(Twi, %Server{users: [], hashtags: %{}}, name: Mainserver)
        :global.sync()
        :global.register_name(:mainserver, pid)
        pid
        Process.sleep(:infinity)
    end
 

    ##this function finds the ip address of the client machine
    def get_client_ip_address() do
        {:ok, ifs} = :inet.getif()
        {a,b,c,d} =
            Enum.filter(ifs , fn({{ip, _, _, _} , _t, _net_mask}) -> ip != 127 end)
            |> Enum.map(fn {ip, _broadaddr, _mask} -> ip end)
            |>List.last
        "#{a}.#{b}.#{c}.#{d}"        
             
    end
end