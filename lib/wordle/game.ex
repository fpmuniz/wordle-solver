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
          guesses: [String.t()],
          right_word: String.t(),
          wordlist: [String.t()]
        }
  @type counts :: %{String.grapheme() => integer()}

  defstruct [:right_word, wordlist: [], guesses: []]

  @spec new([String.t()], String.t()) :: t()
  def new(wordlist, right_word) do
    case right_word in wordlist do
      true -> %Game{wordlist: wordlist, right_word: right_word}
      false -> raise ArgumentError, "'#{right_word}' must be in wordlist."
    end
  end

  @spec guess(t(), String.t()) :: {t(), String.t()}
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

  @spec exact_matches(map(), String.t(), String.t(), integer) :: map()
  def exact_matches(feedback_so_far \\ %{}, guess, word, position \\ 0)
  def exact_matches(feedback_so_far, "", "", _position), do: feedback_so_far

  def exact_matches(feedback_so_far, guess, word, position) do
    {guessed_letter, guess} = String.split_at(guess, 1)
    {correct_letter, word} = String.split_at(word, 1)

    guessed_letter
    |> case do
      ^correct_letter -> feedback_so_far |> Map.put(position, "2")
      _ -> feedback_so_far
    end
    |> exact_matches(guess, word, position + 1)
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
