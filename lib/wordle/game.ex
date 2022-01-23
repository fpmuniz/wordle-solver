defmodule Wordle.Game do
  @moduledoc ~S"""
  Basic state of an wordle game. The struct in this file retains information about the game,
  including the expected word and which guesses have already been taken.

  Usage:
  iex> wordlist = ~w(some word gone)
  iex> game = Game.new(wordlist, "word")
  %Wordle.Game{guesses: [], right_word: "word", wordlist: ["some", "word", "gone"]}
  iex> game = Game.guess(game, "gone")
  iex> game.feedbacks
  ["0200"]
  iex> game = Game.guess(game, "word")
  iex> game.feedbacks
  ["2222", "0200"]
  iex> game.guesses
  ["word", "gone"]
  """

  alias Wordle.Game
  alias Wordle.Feedback

  @type t :: %Game{
          guesses: Lexicon.t(),
          feedbacks: Lexicon.t(),
          right_word: String.t(),
          wordlist: Lexicon.t()
        }
  @type counts :: %{Grapheme.t() => integer()}

  defstruct [:right_word, :wordlist, guesses: [], feedbacks: []]

  @spec new(Lexicon.t(), String.t()) :: t()
  def new(wordlist, right_word) do
    case right_word in wordlist do
      true -> %Game{wordlist: wordlist, right_word: right_word}
      false -> raise ArgumentError, "'#{right_word}' must be in wordlist."
    end
  end

  @spec guess(t(), String.t()) :: t()
  def guess(game, guess) do
    :ok = check_word_validity(game, guess)
    feedback = Feedback.build(game.right_word, guess)

    game
    |> put_guess(guess)
    |> put_feedback(feedback)
  end

  @spec put_guess(t(), String.t()) :: t()
  defp put_guess(game, guess) do
    %{game | guesses: [guess | game.guesses]}
  end

  @spec put_feedback(t(), String.t()) :: t()
  defp put_feedback(game, feedback) do
    %{game | feedbacks: [feedback | game.feedbacks]}
  end

  @spec check_word_validity(t(), String.t()) :: :ok
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
