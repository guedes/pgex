defmodule PGEx.Query do
  use PGEx.Connection.Protocol

  def execute(state, query) do
    data = envelope(:query, query)
    _res = PGEx.Connection.send_message(state, data)
  
    { :ok, result } = process_result( state )

    { :ok, result.columns, result.rows }
  end

  defp process_result(state) do
    { :ok, message } = PGEx.Connection.receive_message(state)
    case message do
      { :read_for_query, _status } -> { :ok, state }
      { :got_columns, columns }   -> 
        state = state.columns(columns)
        process_result(state)
      { :got_values, values }     ->
        rows = state.rows ++ [ values ]
        state = state.rows(rows)
        process_result(state)
      _ -> process_result(state)
    end
  end
end

