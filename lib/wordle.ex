defmodule Wordle do
  @moduledoc ~S"""
  Usage:

  iex> words = ~w(done cant wont play stay opus)
  iex> Wordle.solve(words, "play")
  {:ok, ["play", "done"]}
  """

  alias Wordle.Game
  alias Dictionary
  alias Wordle.Solver

  @spec from_dict(String.t()) :: [String.t()]
  def from_dict(dict_name) do
    Dictionary.import_dictionary("dicts/#{dict_name}.txt")
  end

  @spec to_dict([String.t()], String.t()) :: :ok
  def to_dict(wordlist, dict_name) do
    path = "dicts/#{dict_name}.txt"

    Dictionary.write_to_file(wordlist, path)
  end

  @spec solve([String.t()], String.t()) :: {:ok | :error, [String.t()]}
  def solve(wordlist, right_word) when is_list(wordlist) and is_binary(right_word) do
    solver = Solver.new(wordlist)
    game = Game.new(wordlist, right_word)
    Solver.solve(solver, game)
  end

  @spec solve_randomly([String.t()], String.t()) :: {:ok | :error, [String.t()]}
  def solve_randomly(wordlist, right_word) when is_list(wordlist) and is_binary(right_word) do
    solver = Solver.new(wordlist)
    game = Game.new(wordlist, right_word)
    Solver.solve_randomly(solver, game)
  end
end
