defmodule PGEx.Connection do
  defrecord ConnectionInfo, host: 'localhost', port: 5432, user: System.get_env("USER"), password: "", database: "postgres", socket: nil

  Record.import PGEx.Protocol.Message, as: :proto_msg

  def connect(ConnectionInfo[] = conninfo) do
    :gen_tcp.connect(conninfo.host, conninfo.port, [ { :active, false }, :binary, { :packet, :raw } ], 5000)
  end

  def send_message(sock, proto_msg() = msg) do
    :gen_tcp.send(sock, msg.data)
  end
end
