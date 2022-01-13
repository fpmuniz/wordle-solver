defmodule Language.En do
  @moduledoc false

  @spec normalize(binary) :: binary
  def normalize(word) do
    word
    |> String.replace("'", "")
  end
end
