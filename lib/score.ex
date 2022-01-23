defmodule Score do
  @moduledoc ~S"""
  This module allows you to create statistics about frequency of letters in a given list of words
  (or even strings in general). It is mostly used by the Wordle module, but you can use it manually
  aswell.

  iex> words = ["hi", "hello"]
  iex> frequencies = Score.letter_frequencies(words)
  %{"e" => 1, "h" => 2, "i" => 1, "l" => 2, "o" => 1}
  iex> Score.order_by_scores(words, frequencies)
  ["hello", "hi"]
  """

  @type counts :: %{String.grapheme() => integer()}

  @spec letter_frequencies([String.t()]) :: map
  def letter_frequencies(words) do
    words
    |> Enum.map(&grapheme_count/1)
    |> Enum.reduce(%{}, fn counts, acc ->
      Map.merge(acc, counts, fn _key, count1, count2 -> count1 + count2 end)
    end)
    |> Map.new()
  end

  @spec order_by_scores([String.t()]) :: [String.t()]
  def order_by_scores(words) do
    scores = letter_frequencies(words)
    order_by_scores(words, scores)
  end

  @spec order_by_scores([String.t()], map()) :: [String.t()]
  def order_by_scores(words, letter_frequencies) do
    words
    |> Enum.map(fn word ->
      {word, word_score(word, letter_frequencies)}
    end)
    |> Map.new()
    |> Enum.sort_by(&elem(&1, 1), :desc)
    |> Enum.map(&elem(&1, 0))
  end

  @spec grapheme_count(String.t()) :: %{String.grapheme() => integer()}
  def grapheme_count(word) do
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
