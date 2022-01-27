defmodule Linguistics.Word do
  alias Linguistics.Language

  @type t :: String.t()
  @type grapheme :: String.t()

  @spec uniq(t()) :: t()
  def uniq(word) do
    word
    |> String.graphemes()
    |> Enum.uniq()
    |> Enum.join()
  end

  @spec reduce(t(), any(), (grapheme(), any() -> any())) :: any()
  def reduce(word, acc, fun) do
    word
    |> String.graphemes()
    |> Enum.reduce(acc, fun)
  end

  @spec valid?(t(), Language.t()) :: boolean()
  def valid?(word, language) do
    valid_graphemes = Language.valid_graphemes(language)

    reduce(word, true, fn grapheme, acc ->
      acc and grapheme in valid_graphemes
    end)
  end
end
