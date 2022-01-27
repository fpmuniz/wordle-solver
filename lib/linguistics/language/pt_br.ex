defmodule Linguistics.Language.PtBr do
  alias Linguistics.Grapheme

  @behaviour Linguistics.Language

  @a_accents ~w(ã â á à)
  @c_accents ~w(ç)
  @e_accents ~w(é ê)
  @i_accents ~w(í)
  @o_accents ~w(ó ô õ)
  @u_accents ~w(ú)
  @upper_a_accents ~w(Ã Â Á À)
  @upper_c_accents ~w(Ç)
  @upper_e_accents ~w(É Ê)
  @upper_i_accents ~w(Í)
  @upper_o_accents ~w(Ó Ô Õ)
  @upper_u_accents ~w(Ú)

  @impl true
  @spec normalize(String.t()) :: String.t()
  def normalize(word) do
    word
    |> String.graphemes()
    |> Enum.map_join(&replace_accent/1)
  end

  @impl true
  @spec valid_graphemes() :: [Grapheme.t()]
  def valid_graphemes() do
    ?a..?z
    |> Enum.to_list()
    |> to_string()
    |> String.codepoints()
  end

  @spec replace_accent(Grapheme.t()) :: Grapheme.t()
  defp replace_accent(l) when l in @a_accents, do: "a"
  defp replace_accent(l) when l in @c_accents, do: "c"
  defp replace_accent(l) when l in @e_accents, do: "e"
  defp replace_accent(l) when l in @i_accents, do: "i"
  defp replace_accent(l) when l in @o_accents, do: "o"
  defp replace_accent(l) when l in @u_accents, do: "u"
  defp replace_accent(l) when l in @upper_a_accents, do: "A"
  defp replace_accent(l) when l in @upper_c_accents, do: "C"
  defp replace_accent(l) when l in @upper_e_accents, do: "E"
  defp replace_accent(l) when l in @upper_i_accents, do: "I"
  defp replace_accent(l) when l in @upper_o_accents, do: "O"
  defp replace_accent(l) when l in @upper_u_accents, do: "U"
  defp replace_accent(l), do: l
end
