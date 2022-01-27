defmodule Linguistics.Grapheme do
  alias Linguistics.Lexicon

  @type t :: String.grapheme()
  @type counts :: %{t() => integer()}
  @type score :: %{t() => number()}

  @spec letter_frequencies(Lexicon.t()) :: counts()
  def letter_frequencies(lexicon) do
    lexicon
    |> Enum.map(&counts/1)
    |> Enum.reduce(%{}, fn counts, acc ->
      Map.merge(acc, counts, fn _key, count1, count2 -> count1 + count2 end)
    end)
    |> Map.new()
  end

  @spec order_by_scores(Lexicon.t()) :: Lexicon.t()
  def order_by_scores(lexicon) do
    scores = letter_frequencies(lexicon)
    order_by_scores(lexicon, scores)
  end

  @spec order_by_scores(Lexicon.t(), score()) :: Lexicon.t()
  def order_by_scores(lexicon, letter_frequencies) do
    lexicon
    |> Enum.map(fn word ->
      {word, word_score(word, letter_frequencies)}
    end)
    |> Map.new()
    |> Enum.sort_by(&elem(&1, 1), :desc)
    |> Enum.map(&elem(&1, 0))
  end

  @spec counts(String.t()) :: counts()
  def counts(word) do
    word
    |> String.graphemes()
    |> Enum.frequencies()
  end

  defp word_score(word, letter_frequencies) do
    word
    |> String.graphemes()
    |> Enum.uniq()
    |> Enum.reduce(0, fn letter, acc_score ->
      acc_score + Map.get(letter_frequencies, letter)
    end)
  end
end
