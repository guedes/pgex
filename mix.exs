defmodule Pgex.Mixfile do
  use Mix.Project

  def project do
    [ 
      app: :pgex,
      version: "0.0.1",
      deps: deps,
      test_pattern: "*connection_test.exs" 
    ]
  end

  # Configuration for the OTP application
  def application do
    [
    #mod: {PGEx.App, []}
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    []
  end
end
