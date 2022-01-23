defmodule Dictionary do
  @moduledoc ~S"""
  Allows you to do low-level operations regarding the reading and parsing of a dictionary file.

  You can import a dictionary whose words are separated by line breaks, or simply use a list of
  words you already have. What is usually done is you import the dictionary file, and then parse it
  using the other functions contained in this file.

  iex> words = Dictionary.import_dictionary("dicts/test.txt")
  ["don't", "  clear", "here", "downtown   ", "faces", " study  ", "translate", "we'll", "will", "weren't", "PUMPKIN", "Texas", ""]
  iex> Dictionary.downcase(words)
  ["don't", "  clear", "here", "downtown   ", "faces", " study  ", "translate", "we'll", "will", "weren't", "pumpkin", "texas", ""]
  iex> Dictionary.trim(words)
  ["don't", "clear", "here", "downtown", "faces", "study", "translate", "we'll", "will", "weren't", "PUMPKIN", "Texas", ""]
  iex> Dictionary.filter_valid(words)
  ["here", "faces", "translate", "will"]
  iex> Dictionary.filter_valid(words, ~r/^[A-z']+$/)  # allow
  ["don't", "here", "faces", "translate", "we'll", "will", "weren't", "PUMPKIN", "Texas"]
  iex> Dictionary.filter_number_of_letters(words, 4)
  ["here", "will"]
  """

  @type t :: t()

  @spec import_dictionary(String.t()) :: t()
  def import_dictionary(dict) do
    dict
    |> File.read!()
    |> String.split("\n")
  end

  @spec downcase(t()) :: t()
  def downcase(words), do: words |> Enum.map(&String.downcase/1)

  @spec trim(t()) :: t()
  def trim(words), do: words |> Enum.map(&String.trim/1)

  @spec filter_valid(t(), Regex.t()) :: t()
  def filter_valid(words, pattern \\ ~r/^[a-z]+$/),
    do: words |> Enum.filter(&String.match?(&1, pattern))

  @spec filter_number_of_letters(t(), integer()) :: t()
  def filter_number_of_letters(words, n), do: words |> Enum.filter(&(String.length(&1) == n))

  @spec write_to_file(t(), String.t()) :: :ok
  def write_to_file(words, file_name) do
    words
    |> Enum.join("\n")
    |> String.trim()
    |> (&File.write!(file_name, &1)).()
  end
end
