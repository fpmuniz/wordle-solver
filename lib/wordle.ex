defmodule Wordle do
  @moduledoc ~S"""
  Usage:

  iex> words = ~w(done cant wont play stay opus)
  iex> Wordle.solve(words, "play")
  {:ok, ["play", "done"]}
  """

  alias Wordle.Game
  alias Lexicon
  alias Wordle.Solver

  @spec solve(Lexicon.t(), String.t()) :: {:ok | :error, Lexicon.t()}
  def solve(wordlist, right_word) when is_list(wordlist) and is_binary(right_word) do
    solver = Solver.new(wordlist)
    game = Game.new(wordlist, right_word)
    Solver.solve(solver, game)
  end

  @spec solve_randomly(Lexicon.t(), String.t()) :: {:ok | :error, Lexicon.t()}
  def solve_randomly(wordlist, right_word) when is_list(wordlist) and is_binary(right_word) do
    solver = Solver.new(wordlist)
    game = Game.new(wordlist, right_word)
    Solver.solve_randomly(solver, game)
  end
end
