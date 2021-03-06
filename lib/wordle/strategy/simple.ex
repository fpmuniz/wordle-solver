defmodule Wordle.Strategy.Simple do
  alias Wordle.Feedback
  alias Wordle.Game
  alias Linguistics.Lexicon

  @behaviour Wordle.Strategy

  @impl true
  @spec solve(Lexicon.t(), Game.t()) :: {:ok | :error, Game.t(), Lexicon.t()}
  def solve([], game), do: {:error, game, []}
  def solve(lexicon, %Game{guesses: [hd | _], right_word: hd} = game), do: {:ok, game, lexicon}

  def solve([guess | _] = lexicon, %Game{} = game) do
    game = Game.guess(game, guess)
    [feedback | _] = game.feedbacks

    lexicon
    |> Feedback.filter(guess, feedback)
    |> sort()
    |> solve(game)
  end

  @impl true
  @spec sort(Lexicon.t()) :: Lexicon.t()
  def sort(lexicon), do: Lexicon.order_by_scores(lexicon)
end
