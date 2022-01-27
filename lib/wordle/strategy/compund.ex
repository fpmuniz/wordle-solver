defmodule Wordle.Strategy.Compound do
  alias Wordle.Game
  alias Wordle.Strategy
  alias Linguistics.Lexicon

  @behaviour Wordle.Strategy

  @impl true
  @spec solve(Lexicon.t(), Game.t()) :: {:ok | :error, Game.t(), Lexicon.t()}
  def solve(lexicon, game) do
    with {:error, game, lexicon} <- Strategy.Complements.solve(lexicon, game) do
      Strategy.Simple.solve(lexicon, game)
    end
  end
end
