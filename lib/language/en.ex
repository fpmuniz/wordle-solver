defmodule Language.En do
  @behaviour Language

  @impl true
  @spec valid_graphemes() :: [Grapheme.t()]
  def valid_graphemes() do
    ?a..?z
    |> Enum.to_list()
    |> to_string()
    |> String.codepoints()
  end

  @impl true
  @spec normalize(String.t()) :: String.t()
  def normalize(word) do
    word
    |> String.replace("'", "")
  end
end
