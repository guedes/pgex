defmodule PGEx.Authentication do
  require PGEx.Protocol, as: Proto

  Record.import PGEx.Connection.ConnectionInfo, as: :connection_info
  Record.import PGEx.Protocol.Message, as: :message

  def authenticate(connection_info() = conninfo) do
    PGEx.Connection.send_message(conninfo.socket, message.data(startup_packet(conninfo)))
  end

  defp startup_packet(connection_info() = conninfo) do
    user = Proto.encode(:user, conninfo.user)
    database = Proto.encode(:database,conninfo.database)

    Proto.envelope([ Proto.version, user, database ])
  end
end
