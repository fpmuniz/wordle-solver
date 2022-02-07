defmodule Wordle.Strategy.MaxMinGraph do
  alias Linguistics.Lexicon
  alias Linguistics.Word
  alias Wordle.Feedback
  alias Wordle.Game

  @behaviour Wordle.Strategy
  @classifications [:wrong, :misplaced, :correct]

  @impl true
  @spec solve(Lexicon.t(), Game.t()) :: {:ok | :error, Game.t(), Lexicon.t()}
  def solve([], game), do: {:error, game, []}
  def solve(lexicon, %Game{guesses: [hd | _], right_word: hd} = game), do: {:ok, game, lexicon}

  def solve([guess | _] = lexicon, game) do
    word_size = String.length(game.right_word)
    game = Game.guess(game, guess)
    [feedback | _] = game.feedbacks

    lexicon
    |> Feedback.filter(guess, feedback)
    |> sort(word_size)
    |> solve(game)
  end

  @impl true
  @spec sort(Lexicon.t()) :: Lexicon.t()
  def sort([hd | _] = lexicon), do: sort(lexicon, String.length(hd))

  @spec sort(Lexicon.t(), integer()) :: Lexicon.t()
  def sort(lexicon, word_size) do
    possible_feedbacks = all_possible_feedbacks(word_size)

    lexicon
    |> Task.async_stream(
      fn word ->
        worst_size = worst_feedback_lexicon_size(lexicon, word, possible_feedbacks)

        {word, worst_size}
      end,
      timeout: :infinity
    )
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.sort_by(fn {_word, lexicon_size} -> lexicon_size end)
    |> Enum.map(fn {word, _lexicon_size} -> word end)
  end

  @spec worst_feedback_lexicon_size(Lexicon.t(), Word.t(), [Feedback.t()]) ::
          {integer(), Feedback.t()}
  def worst_feedback_lexicon_size(lexicon, guess, possible_feedbacks) do
    possible_feedbacks
    |> Task.async_stream(&lexicon_size_after_filtering(lexicon, guess, &1), timeout: :infinity)
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.max()
  end

  @spec lexicon_size_after_filtering(Lexicon.t(), Word.t(), Feedback.t()) :: integer()
  def lexicon_size_after_filtering(lexicon, guess, feedback) do
    lexicon
    |> Feedback.filter(guess, feedback)
    |> length()
  end

  @spec all_possible_feedbacks(integer()) :: [[Game.classification()]]
  def all_possible_feedbacks(0), do: [[]]

  def all_possible_feedbacks(word_size) do
    for elem <- @classifications, rest <- all_possible_feedbacks(word_size - 1), do: [elem | rest]
  end
end
