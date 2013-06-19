Code.require_file "../test_helper.exs", __FILE__

defmodule PGEx.Test do
  use ExUnit.Case

  @connection_info "postgresql://pgex:pgex@localhost:5432/test_pgex"

  test :connect do
    conn = PGEx.connect(@connection_info)
    assert is_port(conn.socket)
  end

  test :query do
    conn = PGEx.connect(@connection_info)
    sql  = "SELECT 10 as a, 20 as b"
    assert [ [{"a", 10}, {"b",20}] ] == PGEx.query(conn, sql, :hash_dict)
  end

end
