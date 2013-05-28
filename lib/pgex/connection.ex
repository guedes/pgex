defmodule PGEx.Connection do
  @moduledoc """
  Module responsible to manage connections to the PostgreSQL backend.
  """
  use PGEx.Connection.Protocol
  alias :gen_tcp, as: TCP

  defrecord State, host: 'localhost',
                   host_address: "127.0.0.1", 
                   port: 5432, 
                   user: nil, 
                   password: nil, 
                   database: "postgres", 
                   appname: "pgex", 
                   socket: nil, 
                   status: :connection_bad, 
                   last_query: nil, 
                   last_sqlstate: nil,
                   client_encoding: :sql_ascii,
                   transaction_status: :idle,
                   server_version: nil, 
                   server_pid: nil, 
                   server_cancel_key: nil,
                   columns: [],
                   rows: []

  @doc """
  Establishes a connection to backend using
  the connection information in `connection_info`
  """
  def connect(connection_info) do
    { :ok, state } = parse_connection_info(connection_info)
    { :ok, sock } = TCP.connect(state.host, state.port, [ { :active, false }, :binary, { :packet, :raw } ], 5000)
    { :ok, state } = authenticate(state.socket(sock))
    { :ok, state.socket(sock).status(:connection_ok) }
  end

  @doc """
  Sends enveloped message to backend
  """
  def send_message(state, data) do
    TCP.send(state.socket, data)
  end

  @doc """
  Receives message from backend
  """
  def receive_message(state, timeout // 5000) do
    { :ok, header } = TCP.recv(state.socket, 5, timeout)
    << code :: [ size(8), integer ], size :: [ size(4) , unit(8), integer ] >> = header
    
    if size > 4 do
      { :ok, packet } = TCP.recv(state.socket, size - 4, timeout)
      decode(code, packet)
    else
      { code, <<>> }
    end
  end

  #
  # Private Helper Functions
  #
  defp authenticate(state) do
    startup_packet = build_startup_packet(state)

    send_message(state, startup_packet)

    { :ok , message } = receive_message(state)
    { :authenticate, { code, _salt } } = message

    case code do
      0 -> authentication_setup(state)
      _ -> { :error, :unknow_code }
    end
  end

  defp authentication_setup(state) do
    { :ok, message } = receive_message(state)

    case message do
      { :read_for_query, _status } -> { :ok, state.status(:read_for_query) }
      _ -> authentication_setup(state)
    end
  end

  defp parse_connection_info(<<"postgresql://", _ ::binary>> = connection_info) do
    uri = URI.parse(connection_info)
    
    <<?/, database :: binary >> = uri.path
    [ username, password ] = String.split(uri.userinfo, ":")

    state = State.new(host: binary_to_list(uri.host), port: uri.port, database: database, user: username, password: password)

    { :ok,  state }
  end

  defp parse_connection_info(_) do
    { :error, :connection_bad }
  end

  defp build_startup_packet(state) do
    user = encode(:user, state.user)
    database = encode(:database, state.database)

    envelope([ version , user, database ])
  end
end
