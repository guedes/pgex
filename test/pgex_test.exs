Code.require_file "../test_helper.exs", __FILE__

defmodule PgexTest do
  use ExUnit.Case

  test "connect" do
    conninfo = PGEx.Connection.ConnectionInfo.new(port: 5432)
    assert { :ok, conninfo } = PGEx.Connection.connect(conninfo)
    assert { :ok, conninfo } = PGEx.Authentication.authenticate(conninfo)
    assert { :ok, result }   = PGEx.Query.execute(conninfo, "SELECT 1")
  end

  test "a simple example that IS NOT passing yet" do
    PGEx.connect
    assert Enum.member? PGEx.tables, "pg_class"

  end
end
