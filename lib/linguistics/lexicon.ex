defmodule Linguistics.Lexicon do
  alias Linguistics.Word

  @type t :: [Word.t()]
  @type score :: %{Word.grapheme() => number()}

  @path "lib/linguistics/lexicon"

  @spec import(String.t()) :: t()
  def import(name) do
    "#{@path}/#{name}.txt"
    |> File.read!()
    |> String.split("\n")
  end

  @spec downcase(t()) :: t()
  def downcase(lexicon) do
    Enum.map(lexicon, &String.downcase/1)
  end

  @spec trim(t()) :: t()
  def trim(lexicon) do
    Enum.map(lexicon, &String.trim/1)
  end

  @spec filter_valid(t(), Linguistics.language()) :: t()
  def filter_valid(lexicon, language \\ :en) do
    Enum.filter(lexicon, &Word.valid?(&1, language))
  end

  @spec filter_by_length(t(), integer()) :: t()
  def filter_by_length(lexicon, n) do
    Enum.filter(lexicon, &(String.length(&1) == n))
  end

  @spec letter_frequencies(t()) :: Word.counts()
  def letter_frequencies(lexicon) do
    lexicon
    |> Enum.map(&Word.counts/1)
    |> Enum.reduce(%{}, fn counts, acc ->
      Map.merge(acc, counts, fn _key, count1, count2 -> count1 + count2 end)
    end)
    |> Map.new()
  end

  @spec order_by_scores(t()) :: t()
  def order_by_scores(lexicon) do
    scores = letter_frequencies(lexicon)
    order_by_scores(lexicon, scores)
  end

  @spec order_by_scores(t(), score()) :: t()
  def order_by_scores(lexicon, letter_frequencies) do
    lexicon
    |> Enum.map(fn word ->
      {word, word_score(word, letter_frequencies)}
    end)
    |> Map.new()
    |> Enum.sort_by(&elem(&1, 1), :desc)
    |> Enum.map(&elem(&1, 0))
  end

  defp word_score(word, letter_frequencies) do
    word
    |> String.graphemes()
    |> Enum.uniq()
    |> Enum.reduce(0, fn letter, acc_score ->
      acc_score + Map.get(letter_frequencies, letter)
    end)
  end

  @spec export(t(), String.t()) :: :ok
  def export(lexicon, name) do
    string =
      lexicon
      |> Enum.join("\n")
      |> String.trim()

    File.write!("#{@path}/#{name}.txt", string)
  end
end
