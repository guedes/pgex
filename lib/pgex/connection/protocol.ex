defmodule PGEx.Connection.Protocol do
  defrecord Packet, size: 0, payload: <<>>

  defmacro __using__(_opts) do
    quote do
      require unquote(__MODULE__)
      import unquote(__MODULE__)
    end
  end

  defmacro version do
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
  
  def encode(_data) do
    #IO.puts data
  end

  defmacro return_decoded(codename, values) do
    { :ok, { codename, values } }
  end
  
  def decode(?R, packet) do
    << auth_method :: [ size(32), integer ], salt :: binary >> = packet
    return_decoded(:authenticate, { auth_method, salt })
  end

  def decode(?Z, packet) do
      << state :: [ size(8), integer ] >> = packet
      case state do
        ?I ->
          return_decoded(:read_for_query, :idle)
      end
  end

  def decode(?T, packet) do
    << _total_fields :: [ size(2), unit(8), integer ], rest :: binary >> = packet

    return_decoded(:got_columns, binary_to_columns_descriptions(rest))
  end

  def decode(?D, packet) do
    << _total_fields :: [ size(2), unit(8), integer ], rest :: binary >> = packet
   
    return_decoded(:got_values, binary_to_columns_values(rest))
  end

  def decode(_not_implemented, _packet) do
    return_decoded(:continue, :noop)
  end

  defp binary_to_columns_values(binary) when is_binary(binary) do
    binary_to_columns_values(binary, [])
  end
  
  defp binary_to_columns_values(<<>>, values) do
    values
  end

  defp binary_to_columns_values(binary, values) do
    << size :: [ size(4), unit(8), integer ], rest :: binary >> = binary
    << value :: [ size(size), unit(8), binary ], rest :: binary >> = rest

    binary_to_columns_values(rest, values ++ [ value ])
  end

  defp binary_to_columns_descriptions(binary) when is_binary(binary) do
    binary_to_columns_descriptions(binary, <<>>, [])
  end

  defp binary_to_columns_descriptions(<<>>, _acc, columns) do
    columns
  end
  
  defp binary_to_columns_descriptions(<< 0, rest :: binary >>, acc, columns) do
    # Ignoring by now
    << _table_id  :: [ size(4), unit(8), integer, unsigned ], 
       _column_id :: [ size(2), unit(8), integer, unsigned ],
       _type_id   :: [ size(4), unit(8), integer, unsigned ],
       _type_len  :: [ size(2), unit(8), integer, unsigned ],
       _type_mod  :: [ size(4), unit(8), integer, unsigned ],
       _format    :: [ size(2), unit(8), integer, unsigned ],
       rest :: binary >> = rest

    binary_to_columns_descriptions(rest, <<>>, columns ++ [ acc ])
  end

  defp binary_to_columns_descriptions(<< start :: utf8, rest :: binary >>, acc, columns) do
    binary_to_columns_descriptions(rest, acc <> <<start>>, columns)
  end

end
