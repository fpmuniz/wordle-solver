defmodule Linguistics.Language do
  alias Linguistics.Language.En
  alias Linguistics.Language.PtBr
  alias Linguistics.Grapheme
  alias Linguistics.Lexicon

  @type t :: :en | :pt_br

  @languages %{
    en: En,
    pt_br: PtBr
  }

  @callback normalize(word :: String.t()) :: String.t()
  @callback valid_graphemes() :: [Grapheme.t()]

  @spec normalize(Lexicon.t(), t()) :: Lexicon.t()
  def normalize(lexicon, language) do
    module = get_language!(language)

    Enum.map(lexicon, &module.normalize/1)
  end

  @spec valid_graphemes(t()) :: [Grapheme.t()]
  def valid_graphemes(language) do
    module = get_language!(language)
    module.valid_graphemes()
  end

  @spec get_language!(t()) :: module()
  defp get_language!(lang) do
    case Map.get(@languages, lang) do
      nil -> raise ArgumentError, message: "Language #{lang} is not supported."
      module -> module
    end
  end
end
