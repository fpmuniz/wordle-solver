defmodule Wordle.Strategy.MinDepth do
  alias Linguistics.Lexicon
  alias Linguistics.Word
  alias Wordle.Feedback
  alias Wordle.Game

  @behaviour Wordle.Strategy
  @classifications [:wrong, :misplaced, :correct]
  @depth 3

  @spec solve(Lexicon.t(), Game.t()) :: {:ok | :error, Game.t(), Lexicon.t()}
  def solve([], game), do: {:error, game, []}
  def solve(lexicon, %Game{guesses: [hd | _], right_word: hd} = game), do: {:ok, game, lexicon}

  def solve([guess | _] = lexicon, game) do
    game = Game.guess(game, guess)
    [feedback | _] = game.feedbacks

    lexicon
    |> Feedback.filter(guess, feedback)
    |> sort()
    |> solve(game)
  end

  @spec sort(Lexicon.t()) :: Lexicon.t()
  def sort(lexicon) do
    lexicon
    |> Enum.map(fn word -> {word, depth(lexicon, word)} end)
    # |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.sort_by(fn {_word, depth} -> depth end)
    |> Enum.map(fn {word, _depth} -> word end)
  end

  @spec depth(Lexicon.t(), integer()) :: integer()
  def depth(lexicon, max \\ @depth)
  def depth([guess | _] = lexicon, max), do: depth(lexicon, guess, max)
  def depth([], _max), do: 0

  @spec depth(Lexicon.t(), Word.t(), integer()) :: integer()
  def depth([], _guess, _max), do: 0
  def depth(_lexicon, _guess, 0), do: 1
  def depth([_word], _guess, _max), do: 1

  def depth(lexicon, guess, max) when max > 0 do
    guess
    |> String.length()
    |> all_possible_feedbacks()
    |> Task.async_stream(
      fn feedback ->
        lexicon
        |> Feedback.filter(guess, feedback)
        |> depth(max - 1)
      end,
      timeout: :infinity
    )
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.max()
    |> Kernel.+(1)
  end

  @spec all_possible_feedbacks(integer()) :: [[Game.classification()]]
  def all_possible_feedbacks(0), do: [[]]

  def all_possible_feedbacks(word_size) do
    for elem <- @classifications, rest <- all_possible_feedbacks(word_size - 1), do: [elem | rest]
  end
end
