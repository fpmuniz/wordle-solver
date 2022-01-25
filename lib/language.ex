defmodule Language do
  @moduledoc ~S"""
  Interface that allows you to convert all characters from a language into simpler ones. For
  instance, you may want to convert accents into unaccented letters, or remove apostrophes from
  the game. Currently only PT-BR and EN are supported.

  iex> Language.normalize(["olá", "avião", "quântico"], :pt_br)
  ["ola", "aviao", "quantico"]

  iex> Language.normalize(["don't", "weren't"], :en)
  ["dont", "werent"]
  """

  alias Language.En
  alias Language.PtBr

  @languages %{
    en: En,
    pt_br: PtBr
  }

  @callback normalize(word :: String.t()) :: String.t()
  @callback valid_graphemes() :: [Grapheme.t()]

  @spec normalize(Lexicon.t(), atom()) :: Lexicon.t()
  def normalize(lexicon, language) do
    module = get_language!(language)

    Enum.map(lexicon, &module.normalize/1)
  end

  @spec valid_graphemes(atom()) :: [Grapheme.t()]
  def valid_graphemes(language) do
    module = get_language!(language)
    module.valid_graphemes()
  end

  defp get_language!(lang) do
    case Map.get(@languages, lang) do
      nil -> raise ArgumentError, message: "Language #{lang} is not supported."
      module -> module
    end
  end
end
