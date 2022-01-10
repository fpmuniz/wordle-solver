defmodule Parser do
  @spec import_dictionary(String.t()) :: [String.t()]
  def import_dictionary(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n")
  end

  @spec parse_words([String.t()]) :: [String.t()]
  def parse_words(words) do
    words
    |> Enum.map(&parse_word/1)
    |> Enum.sort()
  end

  defp parse_word(word) do
    word
    |> String.downcase()
    |> String.trim()
  end
end
