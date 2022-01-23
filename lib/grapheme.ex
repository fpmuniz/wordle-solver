defmodule Grapheme do
  @moduledoc ~S"""
  This module allows you to create statistics about frequency of letters in a given list of words
  (or even strings in general). It is mostly used by the Wordle module, but you can use it manually
  aswell.

  iex> words = ["hi", "hello"]
  iex> frequencies = Grapheme.letter_frequencies(words)
  %{"e" => 1, "h" => 2, "i" => 1, "l" => 2, "o" => 1}
  iex> Grapheme.order_by_scores(words, frequencies)
  ["hello", "hi"]
  """

  @type t :: String.grapheme()

  @typedoc """
  A map containing a count of graphemes as values and the graphemes themselves as keys.
  """
  @type counts :: %{t() => integer()}

  @spec letter_frequencies(Dictionary.t()) :: map
  def letter_frequencies(dict) do
    dict
    |> Enum.map(&counts/1)
    |> Enum.reduce(%{}, fn counts, acc ->
      Map.merge(acc, counts, fn _key, count1, count2 -> count1 + count2 end)
    end)
    |> Map.new()
  end

  @spec order_by_scores(Dictionary.t()) :: Dictionary.t()
  def order_by_scores(dict) do
    scores = letter_frequencies(dict)
    order_by_scores(dict, scores)
  end

  @spec order_by_scores(Dictionary.t(), map()) :: Dictionary.t()
  def order_by_scores(dict, letter_frequencies) do
    dict
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
