defmodule WordStats do
  @moduledoc ~S"""
  This module allows you to create statistics about frequency of letters in a given list of words
  (or even strings in general). It is mostly used by the Wordle module, but you can use it manually
  aswell.

  iex> words = ["hi", "hello"]
  iex> frequencies = WordStats.letter_frequencies(words)
  %{
    "e" => 0.14285714285714285,
    "h" => 0.2857142857142857,
    "i" => 0.14285714285714285,
    "l" => 0.2857142857142857,
    "o" => 0.14285714285714285
  }
  iex> WordStats.order_by_scores(words, frequencies)
  ["hello", "hi"]
  """

  @spec letter_frequencies([binary]) :: map
  def letter_frequencies(words) do
    total = Enum.reduce(words, 0, fn word, acc -> acc + String.length(word) end)

    words
    |> Enum.map(&get_letter_count/1)
    |> Enum.reduce(%{}, fn counts, acc ->
      Map.merge(acc, counts, fn _key, count1, count2 -> count1 + count2 end)
    end)
    |> Enum.map(fn {letter, count} -> {letter, count / total} end)
    |> Map.new()
  end

  @spec order_by_scores([binary], map()) :: [binary]
  def order_by_scores(words, letter_frequencies) do
    words
    |> Enum.map(fn word ->
      {word, word_score(word, letter_frequencies)}
    end)
    |> Map.new()
    |> Enum.sort_by(&elem(&1, 1), :desc)
    |> Enum.map(&elem(&1, 0))
  end

  defp word_score(word, letter_frequencies) do
    word
    |> String.codepoints()
    |> Enum.uniq()
    |> Enum.reduce(0, fn letter, acc_score ->
      acc_score + Map.get(letter_frequencies, letter)
    end)
  end

  defp get_letter_count(word) do
    word
    |> String.codepoints()
    |> Enum.frequencies()
  end
end
