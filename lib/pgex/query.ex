defmodule PGEx.Query do
  use PGEx.Connection.Protocol

  def execute(state, query) do
    data = envelope(:query, query)
    _res = PGEx.Connection.send_message(state, data)

    { :ok, result } = process_result( state )

    { :ok, Enum.map(result.columns, fn({ name, _}) -> name end), result.rows }
  end

  defp process_result(state) do
    { :ok, message } = PGEx.Connection.receive_message(state)
    case message do
      { :read_for_query, _status } -> { :ok, state }
      { :got_columns, columns }    ->
        state = state.columns(columns)
        process_result(state)
      { :got_values, values }      ->
        values = cast_values(values, state.columns)
        rows = state.rows ++ [ values ]
        state = state.rows(rows)
        process_result(state)
      _ -> process_result(state)
    end
  end

  defp cast_values(values, columns) when is_list(values) and is_list(columns) do
    Enum.map values, fn(value, idx) ->

      { _, type_id } = Enum.at(columns, idx)

      cond do
        type_id == 16 -> value == "t"
        Enum.member?([ 20, 21, 23 ], type_id) -> value |> binary_to_list |> list_to_integer
        true -> value
      end
    end
  end


end

