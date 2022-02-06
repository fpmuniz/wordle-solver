defmodule Linguistics do
  @type grapheme :: Linguistics.Word.grapheme()
  @type word :: Linguistics.Word.t()
  @type language :: Linguistics.Language.t()
  @type lexicon :: Linguistics.Lexicon.t()
  @type counts :: %{grapheme() => integer()}
  @type scores :: %{grapheme() => number()}
end
