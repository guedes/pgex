Code.require_file "../test_helper.exs", __FILE__

defmodule PGExClientTest do
  use ExUnit.Case

  test "query" do
    assert { :ok, conn } = PGEx.Connection.connect("postgresql://guedes:senha@localhost:5432/banco")

    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT 1 as result")
    assert columns == ["result"]
    assert rows == [["1"]]

    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT 1+1 as a, 2+3 as b")
    assert columns == ["a","b"]
    assert rows != [["2","4"]]
    assert rows == [["2","5"]]

    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT 1 as a, 2 as b, 3 as c, 4 as d")
    assert columns == ["a","b","c","d"]
    assert rows == [["1","2","3","4"]]
    
    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT relname,relkind FROM pg_class LIMIT 2")
    assert columns == ["relname","relkind"]
    assert rows == [["pg_statistic","r"],["pg_type","r"]]
  end

  test "more complex queries" do
    assert { :ok, conn } = PGEx.Connection.connect("postgresql://guedes:senha@localhost:5432/banco")

    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT * FROM pg_class")
  end
end
