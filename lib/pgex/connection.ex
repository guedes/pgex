defmodule PGEx.Connection do
  alias :gen_tcp, as: TCP
  alias PGEx.Protocol, as: Proto

  defrecord ConnectionInfo, host: 'localhost', port: 5432, user: System.get_env("USER"), password: "", database: "postgres", socket: nil

  Record.import PGEx.Protocol.Message, as: :proto_msg

  def connect(ConnectionInfo[] = conninfo) do
    { :ok, sock } = :gen_tcp.connect(conninfo.host, conninfo.port, [ { :active, false }, :binary, { :packet, :raw } ], 5000)
    { :ok, conninfo.socket(sock) }
  end

  def send_message(sock, data) do
    :gen_tcp.send(sock, data)
  end

  def receive_message(sock, timeout // 5000) do
    { :ok, header } = TCP.recv(sock, 5, timeout)
    << code :: [ size(8), integer ], size :: [ size(4) , unit(8), integer ] >> = header
    
    if size > 4 do
      { :ok, packet } = TCP.recv(sock, size - 4, timeout)
      Proto.decode(code, packet)
    else
      { code, <<>> }
    end
  end
end
