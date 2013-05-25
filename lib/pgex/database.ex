defmodule PGEx.Database do
  @doc false
  defmacro __using__(_opts) do
    quote do
      import PGEx
      require PGEx
    end
  end
end
