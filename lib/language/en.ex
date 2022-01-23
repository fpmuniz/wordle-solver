defmodule Language.En do
  @moduledoc false
  @behaviour Language

  @impl true
  @spec normalize(String.t()) :: String.t()
  def normalize(word) do
    word
    |> String.replace("'", "")
  end
end
