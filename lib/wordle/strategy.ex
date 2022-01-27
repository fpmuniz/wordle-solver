defmodule Wordle.Strategy do
  alias Wordle.Game
  alias Wordle.Strategy.Compound
  alias Wordle.Strategy.Complements
  alias Wordle.Strategy.MissingGraphemes
  alias Wordle.Strategy.Simple
  alias Wordle.Strategy.Random

  alias Linguistics.Lexicon

  @callback solve(Lexicon.t(), Game.t()) :: {:ok | :error, Game.t(), Lexicon.t()}

  @strategies %{
    simple: Simple,
    random: Random,
    complements: Complements,
    compound: Compound,
    missing_graphemes: MissingGraphemes
  }

  @spec solve(Lexicon.t(), String.t(), atom()) :: {:ok | :error, Lexicon.t()}
  def solve(lexicon, right_word, strategy \\ :simple) do
    strategy_module = get_strategy!(strategy)
    game = Game.new(lexicon, right_word)
    {status, game, _lexicon} = strategy_module.solve(lexicon, game)
    {status, game.guesses}
  end

  @spec get_strategy!(atom()) :: module()
  defp get_strategy!(strategy) do
    case @strategies[strategy] do
      nil -> raise ArgumentError, message: "Invalid strategy atom `#{strategy}`."
      module -> module
    end
  end
end
