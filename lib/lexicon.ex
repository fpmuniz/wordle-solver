defmodule Lexicon do
  @moduledoc ~S"""
  Allows you to do low-level operations regarding the reading and parsing of a lexicon file.

  You can import a lexicon whose words are separated by line breaks, or simply use a list of
  words you already have. What is usually done is you import the lexicon file, and then parse it
  using the other functions contained in this file.

  iex> words = Lexicon.import("test")
  ["don't", "  clear", "here", "downtown   ", "faces", " study  ", "translate", "we'll", "will", "weren't", "PUMPKIN", "Texas", ""]
  iex> Lexicon.downcase(words)
  ["don't", "  clear", "here", "downtown   ", "faces", " study  ", "translate", "we'll", "will", "weren't", "pumpkin", "texas", ""]
  iex> Lexicon.trim(words)
  ["don't", "clear", "here", "downtown", "faces", "study", "translate", "we'll", "will", "weren't", "PUMPKIN", "Texas", ""]
  iex> Lexicon.filter_valid(words)
  ["here", "faces", "translate", "will"]
  iex> Lexicon.filter_valid(words, ~r/^[A-z']+$/)  # allow
  ["don't", "here", "faces", "translate", "we'll", "will", "weren't", "PUMPKIN", "Texas"]
  iex> Lexicon.filter_by_number_of_graphenes(words, 4)
  ["here", "will"]
  """

  @type t :: [String.t()]

  @spec import(String.t()) :: t()
  def import(name) do
    "dicts/#{name}.txt"
    |> File.read!()
    |> String.split("\n")
  end

  @spec downcase(t()) :: t()
  def downcase(dict), do: dict |> Enum.map(&String.downcase/1)

  @spec trim(t()) :: t()
  def trim(dict), do: dict |> Enum.map(&String.trim/1)

  @spec filter_valid(t(), Regex.t()) :: t()
  def filter_valid(dict, pattern \\ ~r/^[a-z]+$/),
    do: dict |> Enum.filter(&String.match?(&1, pattern))

  @spec filter_by_number_of_graphenes(t(), integer()) :: t()
  def filter_by_number_of_graphenes(dict, n), do: dict |> Enum.filter(&(String.length(&1) == n))

  @spec export(t(), String.t()) :: :ok
  def export(dict, name) do
    dict
    |> Enum.join("\n")
    |> String.trim()
    |> (&File.write!("dicts/#{name}.txt", &1)).()
  end
end
