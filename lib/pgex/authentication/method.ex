defmodule PGEx.Authentication.Method do
  use Behaviour

  @type state :: Connection.State.t

  defcallback authenticate(state) :: state
end


defmodule PGEx.Authentication.Method.AuthenticationOK do
  @behaviour PGEx.Authentication.Method.Behaviour

  def authenticate(conn), do: conn.status(:connected)
end

defmodule PGEx.Authentication.Method.CleartextPassword do
  @behaviour PGEx.Authentication.Method.Behaviour
  
  def authenticate(conn), do: conn.status(:connected)
end

defmodule PGEx.Authentication.Method.MD5Password do
  @behaviour PGEx.Authentication.Method.Behaviour

  def authenticate(conn) do
    IO.inspect _md5([_md5([conn.user, conn.password]), conn.salt])

  #PGEx.Connection.send_message(conn, _md5(_md5(conn.user <> conn.password)<>conn.salt))
  end

  defp _md5(list) when is_list(list) do
     List.flatten lc <<b>> inbits :erlang.md5(list), do: :io_lib.format("~2.16.0b", [b])
  end

  defp _md5(binary) when is_binary(binary) do
    _md5([binary])
  end
end

