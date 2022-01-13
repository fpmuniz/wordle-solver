defmodule Language.PtBr do
  @a_accents ~w(ã â á à)
  @c_accents ~w(ç)
  @e_accents ~w(é ê)
  @i_accents ~w(í)
  @o_accents ~w(ó ô õ)
  @u_accents ~w(ú)
  @valid_letters ?a..?z |> Enum.to_list() |> List.to_string() |> String.codepoints()

  def normalize(word) do
    word
    |> String.codepoints()
    |> Enum.map_join(&replace_accent/1)
  end

  defp replace_accent(l) when l in @a_accents, do: "a"
  defp replace_accent(l) when l in @c_accents, do: "c"
  defp replace_accent(l) when l in @e_accents, do: "e"
  defp replace_accent(l) when l in @i_accents, do: "i"
  defp replace_accent(l) when l in @o_accents, do: "o"
  defp replace_accent(l) when l in @u_accents, do: "u"
  defp replace_accent(l) when l in @valid_letters, do: l
end
