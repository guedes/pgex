Code.require_file "../test_helper.exs", __FILE__

defmodule PGEx.Connection.Test do
  use ExUnit.Case

  @connection_info_trust     "postgresql://pgex:pgex@localhost:5437/test_pgex"
  @connection_info_cleartext "postgresql://pgex_cleartext:pgex2@localhost:5437/test_pgex"
  @connection_info_md5       "postgresql://pgex_md5:pgex3@localhost:5437/test_pgex"

  test :connect_trust do
    assert { :ok, conn } = PGEx.Connection.connect(@connection_info_trust)
    assert is_port(conn.socket)
    refute conn.status == :connection_bad
  end

  test :connect_cleartext do
    assert { :ok, conn } = PGEx.Connection.connect(@connection_info_cleartext)
    assert is_port(conn.socket)
    refute conn.status == :connection_bad
  end

  test :connect_md5 do
    assert { :ok, conn } = PGEx.Connection.connect(@connection_info_md5)
    assert is_port(conn.socket)
    refute conn.status == :connection_bad
  end
end
