defmodule Wordle.Game do
  @moduledoc ~S"""
  Basic state of an wordle game. The struct in this file retains information about the game,
  including the expected word and which guesses have already been taken.

  Usage:
  iex> {guesses, _feedback} = Game.guess("word", "test")
  {["test"], "0000"}
  iex> {_guesses, _feedback} = Game.guess("word", "dont", guesses)
  {["dont", "test"], "1200"}
  """

  defmodule UnsolvableError do
    defexception [:message]
  end

  @spec guess(binary, binary, [binary]) :: {[binary], binary}
  def guess(right_word, guess, guesses \\ []) do
    if String.length(right_word) != String.length(guess) do
      raise ArgumentError,
            "guessed word #{guess}, but it should have been #{String.length(right_word)} characters long."
    end

    guesses = [guess | guesses]

    feedback =
      guess
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map_join(fn {letter, pos} ->
        cond do
          letter == String.at(right_word, pos) -> "2"
          String.contains?(right_word, letter) -> "1"
          true -> "0"
        end
      end)

    {guesses, feedback}
  end
end
