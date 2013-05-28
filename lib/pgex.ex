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

  # Yes, this is empty. It's a WIP.
end
