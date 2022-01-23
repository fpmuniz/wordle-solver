defmodule Language.En do
  @moduledoc false

  @spec normalize(String.t()) :: String.t()
  def normalize(word) do
    word
    |> String.replace("'", "")
  end
end
