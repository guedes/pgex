Code.require_file "../test_helper.exs", __FILE__

defmodule PGEx.Query.Test do
  use ExUnit.Case

  test :query do
    assert { :ok, conn } = PGEx.Connection.connect("postgresql://guedes:senha@localhost:5432/banco")

    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT 1 as result")
    assert ["result"] == columns
    assert [[1]]      == rows

    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT '1' as result, 1 = 1 as bool1, 1 = 2 as bool2, 't' as fake, 1234 as number")
    assert ["result","bool1","bool2","fake","number"] == columns
    assert [["1", true, false,"t",1234]]              == rows

    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT 1+1 as a, 2+3 as b")
    assert ["a","b"]   == columns
    assert [[2,4]] != rows
    assert [[2,5]] == rows

    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT 1 as a, 2 as b, '3' as c, 4 as d")
    assert ["a","b","c","d"] == columns
    assert [[1,2,"3",4]]       == rows

    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT relname,relkind FROM pg_class WHERE relname IN ('pg_statistic', 'pg_type')")
    assert ["relname","relkind"]                  == columns
    assert [["pg_statistic","r"],["pg_type","r"]] == rows
  end

  test "more complex queries" do
    assert { :ok, conn } = PGEx.Connection.connect("postgresql://guedes:senha@localhost:5432/banco")
    assert { :ok, _columns, _rows } = PGEx.Query.execute(conn, "SELECT * FROM pg_class ORDER BY relname")
  end

  test "more things in same connection" do
    assert { :ok, conn } = PGEx.Connection.connect("postgresql://guedes:senha@localhost:5432/banco")
    PGEx.Query.execute(conn, "DROP TABLE IF EXISTS test")
    PGEx.Query.execute(conn, "CREATE TABLE test(name text, height integer)")
    PGEx.Query.execute(conn, "INSERT INTO test(name, height) VALUES ('JOHN', 170),('JIMMY', 180),('MARY',195)")

    { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT height, name FROM test")

    assert ["height","name"]                            == columns
    assert [[170, "JOHN"],[180, "JIMMY"],[195, "MARY"]] == rows
  end
end
