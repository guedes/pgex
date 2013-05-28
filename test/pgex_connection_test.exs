Code.require_file "../test_helper.exs", __FILE__

defmodule PGEx.Connection.Test do
  use ExUnit.Case

  test "connect" do
    assert { :ok, conn } = PGEx.Connection.connect("postgresql://guedes:senha@localhost:5432/banco")
    assert is_port(conn.socket)
  end
end
