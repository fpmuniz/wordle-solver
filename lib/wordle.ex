defmodule Wordle do
  @moduledoc ~S"""
  Usage:

  iex> words = ~w(done cant wont play stay opus)
  iex> Wordle.solve(words, "play")
  {:ok, ["play", "done"]}
  """

  alias Wordle.Game
  alias Wordle.Parser
  alias Wordle.Solver

  @spec from_dict(binary) :: Solver.t()
  def from_dict(dict_name) do
    "dicts/#{dict_name}.txt"
    |> Parser.import_dictionary()
    |> Solver.new()
  end

  @spec to_dict([binary], binary) :: :ok
  def to_dict(wordlist, dict_name) do
    path = "dicts/#{dict_name}.txt"

    Parser.write_to_file(wordlist, path)
  end

  @spec solve([binary], binary) :: {:ok | :error, [binary]}
  def solve(wordlist, right_word) when is_list(wordlist) and is_binary(right_word) do
    solver = Solver.new(wordlist)
    game = Game.new(wordlist, right_word)
    Solver.solve(solver, game)
  end
end
