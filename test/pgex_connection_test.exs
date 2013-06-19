Code.require_file "../test_helper.exs", __FILE__

defmodule PGEx.Connection.Test do
  use ExUnit.Case

  @connection_info "postgresql://pgex:pgex@localhost:5432/test_pgex"

  test :connect do
    assert { :ok, conn } = PGEx.Connection.connect(@connection_info)
    assert is_port(conn.socket)
  end
end
