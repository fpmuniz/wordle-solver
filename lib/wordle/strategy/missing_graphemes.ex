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

  @impl true
  def sort(lexicon), do: Lexicon.order_by_scores(lexicon)

  @spec build_scores(Lexicon.t(), Game.t()) :: Linguistics.scores()
  defp build_scores(lexicon, game) do
    lexicon
    |> Lexicon.grapheme_frequencies()
    |> multiply_scores(game)
    |> Map.new()
  end

  @spec multiply_scores(Linguistics.scores(), Game.t()) :: Linguistics.scores()
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
