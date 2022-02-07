defmodule Wordle.Strategy.Random do
  alias Wordle.Feedback
  alias Wordle.Game
  alias Linguistics.Lexicon

  @behaviour Wordle.Strategy

  @impl true
  @spec solve(Lexicon.t(), Game.t()) :: {:ok | :error, Game.t(), Lexicon.t()}
  def solve([], game), do: {:error, game, []}

  def solve(lexicon, %{guesses: [right_word | _], right_word: right_word} = game),
    do: {:ok, game, lexicon}

  def solve(lexicon, game) do
    lexicon = Enum.shuffle(lexicon)
    [guess | _] = lexicon
    game = Game.guess(game, guess)
    [feedback | _] = game.feedbacks

    lexicon
    |> Feedback.filter(guess, feedback)
    |> solve(game)
  end

  @impl true
  @spec sort(Lexicon.t()) :: Lexicon.t()
  def sort(lexicon), do: lexicon
end
