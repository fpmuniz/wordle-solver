defmodule Wordle.Language do
  @moduledoc ~S"""
  Interface that allows you to convert all characters from a language into simpler ones. For
  instance, you may want to convert accents into unaccented letters, or remove apostrophes from
  the game. Currently only PT-BR and EN are supported.

  iex> Language.normalize(["olá", "avião", "quântico"], :pt_br)
  ["ola", "aviao", "quantico"]

  iex> Language.normalize(["don't", "weren't"], :en)
  ["dont", "werent"]
  """
  alias Wordle.Language.{En, PtBr}

  @spec normalize([String.t()], atom()) :: [String.t()]
  def normalize(words, :pt_br), do: words |> Enum.map(&PtBr.normalize/1)
  def normalize(words, :en), do: words |> Enum.map(&En.normalize/1)
end
