defmodule Wordle do
  @moduledoc ~S"""
  Basic state of an solver game. The struct in this file retains information about the game,
  including the sorted word list, according to how likely it is to be the right word; all words that
  have been suggested so far; the scores each letter has; and the name of the file that was used as
  a dictionary.

  Usage:

  iex> words = ~w(done cant wont play stay opus)
  iex> Wordle.solve(words, "play")
  {:ok, ["play", "done"]}
  """

  alias Wordle.{Game, Solver}

  @spec solve([binary], binary) :: {:ok | :error, [binary]}
  def solve(wordlist, right_word) do
    solve(wordlist, right_word, [], wordlist)
  end

  @spec solve([binary], binary, [binary], [binary]) :: {:ok | :error, [binary]}
  def solve(wordlist, right_word, guesses, complement)

  def solve([], _right_word, guesses, _complement), do: {:error, guesses}
  def solve([best_guess | _], best_guess, guesses, _complement), do: {:ok, [best_guess | guesses]}

  def solve(wordlist, right_word, guesses, complement) do
    guess = best_guess(wordlist, complement)
    {guesses, feedback} = Game.guess(right_word, guess, guesses)
    complement = complement |> Solver.complement(guess) |> WordStats.order_by_scores()

    wordlist
    |> Solver.feedback(guess, feedback)
    |> WordStats.order_by_scores()
    |> solve(right_word, guesses, complement)
  end

  @spec feedback([binary], binary, binary) :: [binary]
  defdelegate feedback(wordlist, guess, feedback), to: Solver

  @spec feedback([binary], binary) :: [binary]
  defdelegate feedback(wordlist, feedback), to: Solver

  @spec best_guess([binary], [binary]) :: binary
  def best_guess(_wordlist, [top_score_complement | _]), do: top_score_complement
  def best_guess([top_score_word | _], []), do: top_score_word
end
