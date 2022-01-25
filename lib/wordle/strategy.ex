defmodule Wordle.Strategy do
  @moduledoc ~S"""
  A basic behaviour module with an interface to build new strategies.
  See Wordle.Strategy.Simple for an example.

  You can also use this as the main interface to interact with solving Wordle games using different
  strategies, without needing to worry about underlying structs that will be used.

  iex> lexicon = ~w(hello never again raise error)
  iex> Wordle.Strategy.solve(lexicon, "never")
  {:ok, ["never", "hello"]}
  iex> Wordle.Strategy.solve(lexicon, "never", :compound)
  {:ok, ["never", "hello"]}
  """

  alias Wordle.Game
  alias Wordle.Strategy.Compound
  alias Wordle.Strategy.Complements
  alias Wordle.Strategy.Simple
  alias Wordle.Strategy.Random

  @callback solve(Lexicon.t(), Game.t()) :: {:ok | :error, Game.t(), Lexicon.t()}

  @strategies %{
    simple: Simple,
    random: Random,
    complements: Complements,
    compound: Compound
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
