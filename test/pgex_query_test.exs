Code.require_file "../test_helper.exs", __FILE__

defmodule PGEx.Query.Test do
  use ExUnit.Case
  
  @connection_info "postgresql://pgex:pgex@localhost:5432/test_pgex"

  test :query do
    assert { :ok, conn } = PGEx.Connection.connect(@connection_info)

    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT 1 as result")
    assert columns == ["result"]
    assert rows    == [[1]]

    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT '1' as result, 1 = 1 as bool1, 1 = 2 as bool2, 't' as fake, 1234 as number")
    assert columns == ["result","bool1","bool2","fake","number"]
    assert rows    == [["1", true, false,"t",1234]]

    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT 1+1 as a, 2+3 as b")
    assert columns == ["a","b"]
    assert [[2,4]] != rows
    assert rows    == [[2,5]] 

    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT 1 as a, 2 as b, '3' as c, 4 as d")
    assert columns == ["a","b","c","d"]
    assert rows    == [[1,2,"3",4]]

    assert { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT relname,relkind FROM pg_class WHERE relname IN ('pg_statistic', 'pg_type')")
    assert columns == ["relname","relkind"]
    assert rows    == [["pg_statistic","r"],["pg_type","r"]]
  end

  test "querying pg_class" do
    assert { :ok, conn } = PGEx.Connection.connect(@connection_info)
    assert { :ok, _columns, _rows } = PGEx.Query.execute(conn, "SELECT * FROM pg_class ORDER BY relname")
  end

  test "more things in same connection" do
    assert { :ok, conn } = PGEx.Connection.connect(@connection_info)
    PGEx.Query.execute(conn, "DROP TABLE IF EXISTS test")
    PGEx.Query.execute(conn, "CREATE TABLE test(name text, height integer)")
    PGEx.Query.execute(conn, "INSERT INTO test(name, height) VALUES ('JOHN', 170),('JIMMY', 180),('MARY',195)")

    { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT height, name FROM test")

    assert columns == ["height","name"]
    assert rows    == [[170, "JOHN"],[180, "JIMMY"],[195, "MARY"]]

    PGEx.Query.execute(conn, "UPDATE test SET name = 'J. SMITH' WHERE name = 'JOHN'")

    { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT * FROM test WHERE name = 'J. SMITH'")

    assert columns == ["name", "height"]
    assert rows    == [["J. SMITH", 170]]

    PGEx.Query.execute(conn, "DELETE FROM test WHERE name = 'J. SMITH'")
    
    { :ok, columns, rows } = PGEx.Query.execute(conn, "SELECT * FROM test WHERE name = 'J. SMITH'")

    assert columns      == ["name", "height"]
    assert length(rows) == 0
  end
end
