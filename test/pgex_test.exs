Code.require_file "../test_helper.exs", __FILE__

defmodule PgexTest do
  use ExUnit.Case

  test "connect" do
    conninfo = PGEx.Connection.ConnectionInfo.new(port: 5437)
    assert { :ok, sock } = PGEx.Connection.connect( conninfo )
    conninfo = conninfo.socket(sock)
    PGEx.Authentication.authenticate(conninfo)
  end

  test "a simple example that IS NOT passing yet" do
    PGEx.connect
    assert List.member? PGEx.tables, "pg_class"
  end
end
