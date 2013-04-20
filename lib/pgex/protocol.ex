defmodule PGEx.Protocol do
  defrecord Message, data: <<>>
  defrecord Packet, size: 0, payload: <<>>

  def version do
    <<3 :: [size(16), integer] , 0 :: [size(16) , integer ] >>
  end
  
  def envelope(list) when is_list(list) do
    envelope(encode(list))
  end

  def envelope(binary) when is_binary(binary) do
    size = 4 + size(binary)
    envelope(Packet.new(size: size, payload: binary))
  end

  def envelope(Packet[] = packet) do
    << packet.size :: 32, packet.payload :: binary >>
  end

  def encode(key, value) do
    << to_binary(key) :: binary, 0 :: integer,
       to_binary(value) :: binary, 0 :: integer >>
  end

  def encode(list) when is_list(list) do
    list_to_binary(list ++ [ << 0 :: integer >> ]) 
  end

  def encode(data) do
    IO.puts data
  end

  def decode(Message[] = msg) do
    IO.puts msg.data
  end

end
