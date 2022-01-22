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

  @spec from_dict(binary) :: [binary]
  def from_dict(dict_name) do
    Parser.import_dictionary("dicts/#{dict_name}.txt")
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

  @spec solve_randomly([binary], binary) :: {:ok | :error, [binary]}
  def solve_randomly(wordlist, right_word) when is_list(wordlist) and is_binary(right_word) do
    solver = Solver.new(wordlist)
    game = Game.new(wordlist, right_word)
    Solver.solve_randomly(solver, game)
  end
end
