defmodule Wordle.Strategy.Complements do
  alias Wordle.Feedback
  alias Wordle.Game

  @behaviour Wordle.Strategy

  @impl true
  @spec solve(Lexicon.t(), Game.t()) :: {:ok | :error, Game.t(), Lexicon.t()}
  def solve(lexicon, game) do
    suggestions = lexicon |> get_best_words() |> Enum.reverse()
    solve(lexicon, game, suggestions)
  end

  @spec solve(Lexicon.t(), Game.t(), Lexicon.t()) :: {:ok | :error, Game.t(), Lexicon.t()}
  def solve(lexicon, %Game{guesses: [hd | _], right_word: hd} = game, _), do: {:ok, game, lexicon}

  def solve([hd | _] = lexicon, %Game{right_word: hd} = game, _suggestions) do
    {:ok, Game.guess(game, hd), lexicon}
  end

  def solve(lexicon, game, []), do: {:error, game, lexicon}

  def solve(lexicon, game, [guess | tl]) do
    %{feedbacks: [feedback | _]} = game = Game.guess(game, guess)

    lexicon
    |> Feedback.filter(guess, feedback)
    |> Grapheme.order_by_scores()
    |> solve(game, tl)
  end

  @spec get_best_words(Lexicon.t(), Lexicon.t()) :: Lexicon.t()
  defp get_best_words(lexicon, best_words \\ [])
  defp get_best_words([], best_words), do: best_words

  defp get_best_words([hd | _] = lexicon, best_words) do
    hd
    |> String.graphemes()
    |> Enum.reduce(lexicon, fn grapheme, lexicon -> reject_grapheme(lexicon, grapheme) end)
    |> get_best_words([hd | best_words])
  end

  @spec reject_grapheme(Lexicon.t(), Grapheme.t()) :: Lexicon.t()
  defp reject_grapheme(lexicon, grapheme) do
    Enum.reject(lexicon, &String.contains?(&1, grapheme))
  end
end
