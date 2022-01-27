defmodule Linguistics.Lexicon do
  alias Linguistics.Word

  @type t :: [Word.t()]

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

  @spec export(t(), String.t()) :: :ok
  def export(lexicon, name) do
    lexicon
    |> Enum.join("\n")
    |> String.trim()
    |> (&File.write!("#{@path}/#{name}.txt", &1)).()
  end
end
