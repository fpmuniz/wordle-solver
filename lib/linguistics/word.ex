defmodule Linguistics.Word do
  @type t :: String.t()
  @type grapheme :: String.t()
  @type counts :: %{grapheme() => integer()}

  @spec uniq(t()) :: t()
  def uniq(word) do
    word
    |> String.graphemes()
    |> Enum.uniq()
    |> Enum.join()
  end

  @spec counts(t()) :: counts()
  def counts(word) do
    word
    |> String.graphemes()
    |> Enum.frequencies()
  end

  @spec score(t(), Linguistics.scores()) :: number()
  def score(word, grapheme_scores) do
    word
    |> String.graphemes()
    |> Enum.uniq()
    |> Enum.reduce(0, fn letter, acc_score ->
      acc_score + Map.get(grapheme_scores, letter)
    end)
  end

  @spec reduce(t(), any(), (grapheme(), any() -> any())) :: any()
  def reduce(word, acc, fun) do
    word
    |> String.graphemes()
    |> Enum.reduce(acc, fun)
  end

  @spec valid?(t(), [grapheme()]) :: boolean()
  def valid?(word, valid_graphemes) do
    reduce(word, true, fn grapheme, acc ->
      acc and grapheme in valid_graphemes
    end)
  end
end
