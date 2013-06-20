defmodule PGEx.Connection.Protocol do
  defrecord Packet, size: 0, payload: <<>>

  defmacro __using__(_opts) do
    quote do
      require unquote(__MODULE__)
      import unquote(__MODULE__)
    end
  end

  defmacro version do
    <<3 :: 16, 0 :: 16 >>
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

  def envelope(:password, data) do
    envelope(?p, << to_binary(data) :: binary, 0 :: integer>>)
  end

  def envelope(code, binary) do
    size = 4 + size(binary)
    << code :: 8, size :: 32, binary :: binary >>
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
    << auth_method :: 32, salt :: binary >> = packet
    return_decoded(:authenticate, { auth_method, salt })
  end

  def decode(?Z, packet) do
      << state :: 8 >> = packet
      case state do
        ?I ->
          return_decoded(:read_for_query, :idle)
      end
  end

  def decode(?T, packet) do
    << _total_fields :: 16, rest :: binary >> = packet

    return_decoded(:got_columns, binary_to_columns_descriptions(rest))
  end

  def decode(?D, packet) do
    << _total_fields :: 16, rest :: binary >> = packet

    return_decoded(:got_values, binary_to_columns_values(rest))
  end

  def decode(?E, packet) do
    << size :: [ size(4), unit(8), integer ], rest :: binary >> = packet
    IO.inspect size
    #    IO.inspect message
    IO.inspect rest
    #IO.inspect packet
  end

  def decode(not_implemented, _packet) do
    return_decoded(:continue, :noop)
  end

  defp binary_to_columns_values(binary) when is_binary(binary) do
    binary_to_columns_values(binary, [])
  end

  defp binary_to_columns_values(<<>>, values) do
    values
  end

  defp binary_to_columns_values(<<255, rest :: binary>>, values) do
    binary_to_columns_values(rest, values)
  end

  defp binary_to_columns_values(binary, values) do
    << size :: 32, rest :: binary >> = binary
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
    << _table_id  :: 32 ,
       _column_id :: 16 ,
       type_id    :: 32 ,
       _type_len  :: 16 ,
       _type_mod  :: 32 ,
       _format    :: 16 ,
       rest :: binary >> = rest

    binary_to_columns_descriptions(rest, <<>>, columns ++ [ {acc, type_id} ])
  end

  defp binary_to_columns_descriptions(<< start :: utf8, rest :: binary >>, acc, columns) do
    binary_to_columns_descriptions(rest, acc <> <<start>>, columns)
  end

end
