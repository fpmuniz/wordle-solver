defmodule Wordle.Strategy do
  alias Wordle.Game
  alias Linguistics.Lexicon
  alias Linguistics.Word

  @type scores :: %{Word.grapheme() => number()}

  @callback solve(Lexicon.t(), Game.t()) :: {:ok | :error, Game.t(), Lexicon.t()}
  @callback sort(Lexicon.t()) :: Lexicon.t()
end
