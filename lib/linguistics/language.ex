defmodule Linguistics.Language do
  alias Linguistics.Word

  @callback normalize(word :: String.t()) :: String.t()
  @callback valid_graphemes() :: [Word.grapheme()]
end
