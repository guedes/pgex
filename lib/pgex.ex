defmodule PGEx do

  @doc false
  defmacro __using__(_opts) do
    quote do
      import PGEx
      require PGEx
    end
  end

  def establish_connection(args // nil) do
    nil
  end

  def query(conn, sql) do
    [
      [ calc: 1, result: "TEST" ],
      [ calc: 3, result: "TESTA" ]
    ]
  end

  def connect(args // nil) do
    { :ok, args }
  end

  def tables do
    [ "teste1", "teste2" ]
  end
end
