defmodule PGEx do

  def connect(args // nil) do
    { :ok, self() }
  end

  def tables do
    [ "teste1", "teste2" ]
  end
end
