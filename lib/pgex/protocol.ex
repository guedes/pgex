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

  def envelope(:query, query) do
    envelope(?Q, << to_binary(query) :: binary, 0 :: integer>>)
  end

  def envelope(code, binary) do
    size = 4 + size(binary)
    << code :: 8, size :: [ size(4), unit(8), integer ], binary :: binary >>
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

  def decode(code, packet) do
    ret = fn(codename, values) -> { :ok, { codename, values } } end
    case code do
      ?R ->
	      << auth_method :: [ size(32), integer ], salt :: binary >> = packet

        ret.(:authenticate, { auth_method, salt })
      ?Z ->
        << state :: [ size(8), integer ] >> = packet
        case state do
          ?I ->
            ret.(:read_for_query, :idle)
        end
      _ -> ret.(:continue, :noop)
    end
  end
end
