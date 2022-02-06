defmodule Wordle.Strategy.MissingGraphemes do
  alias Wordle.Game
  alias Wordle.Feedback
  alias Linguistics.Lexicon

  @behaviour Wordle.Strategy

  @impl true
  @spec solve(Lexicon.t(), Game.t()) :: {:ok | :error, Game.t(), Lexicon.t()}
  def solve([], game), do: {:error, game, []}
  def solve(lexicon, %Game{guesses: [hd | _], right_word: hd} = game), do: {:ok, game, lexicon}

  def solve(lexicon, game) do
    scores = build_scores(lexicon, game)
    [guess | _] = lexicon = Lexicon.order_by_scores(lexicon, scores)
    %{feedbacks: [feedback | _]} = game = Game.guess(game, guess)

    lexicon
    |> Feedback.filter(feedback)
    |> solve(game)
  end

  @spec build_scores(Lexicon.t(), Game.t()) :: Lexicon.score()
  defp build_scores(lexicon, game) do
    lexicon
    |> Lexicon.letter_frequencies()
    |> multiply_scores(game)
    |> Map.new()
  end

  @spec multiply_scores(Lexicon.score(), Game.t()) :: Lexicon.score()
  defp multiply_scores(scores, game) do
    scores
    |> Enum.map(fn {grapheme, score} ->
      case game.graphemes[grapheme] do
        :unknown -> {grapheme, score}
        :wrong -> {grapheme, 0}
        :misplaced -> {grapheme, score}
        :correct -> {grapheme, 0}
      end
    end)
    |> Map.new()
  end
end
