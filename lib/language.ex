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

  @callback normalize(word :: String.t()) :: String.t()

  @spec normalize(Dictionary.t(), atom()) :: Dictionary.t()
  def normalize(dict, :pt_br), do: dict |> Enum.map(&PtBr.normalize/1)
  def normalize(dict, :en), do: dict |> Enum.map(&En.normalize/1)
end
