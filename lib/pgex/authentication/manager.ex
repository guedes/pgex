defmodule PGEx.Authentication.Manager do
  alias PGEx.Authentication
  alias PGEx.Connection
  alias :gen_tcp, as: TCP

  def authenticate(conn, auth_info) do

    { auth_type, salt } = auth_info

    conn = case choose_auth_method(conn, auth_type) do
      { :ok, auth_method } -> auth_method.authenticate(conn.salt(salt))
      { :error, error }    -> conn.status(error)
    end

    authentication_setup(conn)
  end

  defp request_auth_type(conn) do
    { :ok , message } = Connection.receive_message(conn)
    { :authenticate, { code, _salt } } = message

    case code do
      0 -> authentication_setup(conn)
      _ -> { :error, :unknow_code }
    end
  end

  defp authentication_setup(conn) do
    { :ok, message } = Connection.receive_message(conn)

    case message do
      { :read_for_query, _status } -> { :ok, conn.status(:read_for_query) }
      _ -> authentication_setup(conn)
    end
  end

  defp choose_auth_method(conn, auth_type) do
    case auth_type do
      0 -> { :ok, Authentication.Method.AuthenticationOK }
      3 -> { :ok, Authentication.Method.CleartextPassword }
      5 -> { :ok, Authentication.Method.MD5Password }
      _ -> { :error, :unsupported_auth_method }
    end
  end
end
