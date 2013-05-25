Code.require_file "../test_helper.exs", __FILE__

defmodule PGExClientTest do
  use ExUnit.Case
  use PGEx

  test "it queries a local database" do
    conn = establish_connection
    assert [ calc: 1, result: "TEST" ] == Enum.first(query(conn, "SELECT 1+1 as calc, 'TEST' as result"))
  end
end
