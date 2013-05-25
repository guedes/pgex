defmodule PGEx.Query do
  require PGEx.Protocol, as: Proto

  Record.import PGEx.Connection.ConnectionInfo, as: :connection_info
  Record.import PGEx.Protocol.Message,          as: :message

  def execute(connection_info() = conninfo, query) do
    data = Proto.envelope(:query, query)
    res = PGEx.Connection.send_message(conninfo.socket, data)

    { code, message } = _r( conninfo )

    IO.inspect code
    IO.inspect message

    { res, "1" }
  end

  defp _r(connection_info() = conninfo) do
    { :ok, message } = PGEx.Connection.receive_message(conninfo.socket)
    IO.inspect message
    case message do
      { :read_for_query, status } -> { :ok, status }
      _ -> _r(conninfo)
    end
  end
end

