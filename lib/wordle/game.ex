defmodule Wordle.Game do
  @moduledoc ~S"""
  Basic state of an wordle game. The struct in this file retains information about the game,
  including the expected word and which guesses have already been taken.

  Usage:
  iex> wordlist = ~w(some word gone)
  iex> game = Game.new(wordlist, "word")
  %Wordle.Game{guesses: [], right_word: "word", wordlist: ["some", "word", "gone"]}
  iex> {game, feedback} = Game.guess(game, "gone")
  iex> feedback
  "0200"
  iex> {game, feedback} = Game.guess(game, "word")
  iex> feedback
  "2222"
  iex> game.guesses
  ["word", "gone"]
  """

  alias Wordle.Game

  @type t :: %Game{
          guesses: [binary()],
          right_word: binary(),
          wordlist: [binary()]
        }

  defstruct [:right_word, wordlist: [], guesses: []]

  @spec new([binary()], binary()) :: t()
  def new(wordlist, right_word) do
    case right_word in wordlist do
      true -> %Game{wordlist: wordlist, right_word: right_word}
      false -> raise ArgumentError, "'#{right_word}' must be in wordlist."
    end
  end

  @spec guess(t(), binary()) :: {t(), binary()}
  def guess(game, guess) do
    :ok = check_word_validity(game, guess)
    guesses = [guess | game.guesses]

    feedback =
      guess
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map_join(fn {letter, pos} ->
        cond do
          letter == String.at(game.right_word, pos) -> "2"
          String.contains?(game.right_word, letter) -> "1"
          true -> "0"
        end
      end)

    {%{game | guesses: guesses}, feedback}
  end

  defp check_word_validity(game, guess) do
    cond do
      guess not in game.wordlist ->
        raise ArgumentError, "'#{guess}' is not in wordlist"

      String.length(game.right_word) != String.length(guess) ->
        raise ArgumentError,
              "guessed word '#{guess}' should have been #{String.length(game.right_word)} characters long."

      true ->
        :ok
    end
  end
end
