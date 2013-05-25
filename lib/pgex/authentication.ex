defmodule PGEx.Authentication do
  alias PGEx.Protocol,                  as: Proto
  alias PGEx.Connection.ConnectionInfo, as: ConnectionInfo
  alias PGEx.Protocol.Message,          as: Message
  alias :gen_fsm,                       as: F

#  def authenticate(ConnectionInfo[] = conninfo) do
#    F.start(__MODULE__, [conninfo], [])
#  end
#
#  def start_link(ConnectionInfo[] = conninfo) do
#    F.start_link(__MODULE__, [conninfo], [])
#  end


  def authenticate(ConnectionInfo[] = conninfo) do
    :ok = PGEx.Connection.send_message(conninfo.socket, _startup_packet(conninfo))

    _auth(conninfo)
  end

  defp _auth(ConnectionInfo[] = conninfo) do
    { :ok, message } = PGEx.Connection.receive_message(conninfo.socket)

    { :authenticate, { code, _salt } } = message

    case code do
      0 -> _setup(conninfo)
      _ -> { :error, :unknow_code }
    end
  end

  defp _startup_packet(ConnectionInfo[] = conninfo) do
    user = Proto.encode(:user, conninfo.user)
    database = Proto.encode(:database,conninfo.database)

    Proto.envelope([ Proto.version, user, database ])
  end

  defp _setup(ConnectionInfo[] = conninfo, params // []) do
    { :ok, message } = PGEx.Connection.receive_message(conninfo.socket)

    case message do
      { :read_for_query, _status } -> { :ok, conninfo }
      _ -> _setup(conninfo, params)
    end
  end
end
