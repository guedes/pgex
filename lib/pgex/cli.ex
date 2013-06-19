defmodule PGEx.CLI do
  @moduledoc """
  Handle commands and dispatch then
  to database using internal functions
  """
  import PGEx.TableFormatter, only: [ print_result: 1 ]

  def run(argv) do
    argv |> parse_args |> process
  end

  def process(:help) do
    IO.puts "Usage: pgex <query>"
  end

  def process(query) do
    PGEx.connect("postgresql://guedes:senha@localhost:5432/banco")
      |> PGEx.query( query, format: :hash_dict )
      |> print_result
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv,  switches: [ help: :boolean ],
                                      aliases:  [ h:     :help   ])
    case parse do
      { [ help: true], _ }  -> :help
      { _, [ query ] }      -> query
      _                     -> :help
    end
  end

end
