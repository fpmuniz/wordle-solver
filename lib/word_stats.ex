defmodule WordStats do
  @spec filter_words_by_size([String.t()], integer) :: [String.t()]
  def filter_words_by_size(words, size) do
    Enum.filter(words, &(String.length(&1) == size))
  end

  @spec letter_frequencies([String.t()]) :: map
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
