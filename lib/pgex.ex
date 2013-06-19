defmodule PGEx do
  @moduledoc """
  Main module that is an interface to underling functions
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      import PGEx
      require PGEx
    end
  end

  @doc """
  Start PGEx
  """
  def start do
    :ok = Application.start(:pgex)
  end

  def connect(url // "postgresql://guedes:senha@localhost:5432/banco") do
    case PGEx.Connection.connect(url) do
      { :ok, conn }     -> conn
      { :error, error } -> error
    end
  end

  def query(conn, sql) do
    { :ok, columns, rows } = conn |> PGEx.Query.execute( sql )

    { columns, rows }
  end

  def query(conn, sql, :hash_dict) do
    { columns, rows } = query(conn, sql)

    Enum.map(rows, Enum.zip(columns, &1))
  end

end
