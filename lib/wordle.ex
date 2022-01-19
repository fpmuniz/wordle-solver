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
    complements = Solver.first_guesses(wordlist)
    solve(wordlist, right_word, [], complements)
  end

  @spec solve([binary], binary, [binary], [binary]) :: {:ok | :error, [binary]}
  def solve(wordlist, right_word, guesses, complements)
  def solve([], _right_word, guesses, _complements), do: {:error, guesses}
  def solve([best_guess | _], best_guess, guesses, _comp), do: {:ok, [best_guess | guesses]}
  def solve(_wordlist, best_guess, guesses, [best_guess | _]), do: {:ok, [best_guess | guesses]}

  def solve(wordlist, right_word, guesses, [guess | complements]) do
    {guesses, feedback} = Game.guess(right_word, guess, guesses)

    wordlist
    |> Solver.feedback(guess, feedback)
    |> WordStats.order_by_scores()
    |> solve(right_word, guesses, complements)
  end

  def solve(wordlist = [guess | _], right_word, guesses, []) do
    {guesses, feedback} = Game.guess(right_word, guess, guesses)

    wordlist
    |> Solver.feedback(guess, feedback)
    |> WordStats.order_by_scores()
    |> solve(right_word, guesses, [])
  end
end
