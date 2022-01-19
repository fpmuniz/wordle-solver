defmodule Wordle do
  @moduledoc ~S"""
  Usage:

  iex> words = ~w(done cant wont play stay opus)
  iex> Wordle.solve(words, "play")
  {:ok, ["play", "done"]}
  """

  alias Wordle.{Game, Solver}

  @spec solve([binary] | Solver.t(), binary | Game.t()) :: {:ok | :error, [binary]}
  def solve(wordlist, right_word) when is_list(wordlist) and is_binary(right_word) do
    solver = Solver.new(wordlist)
    game = Game.new(wordlist, right_word)
    Solver.solve(solver, game)
  end
end
