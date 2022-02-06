defmodule IntegrationTest do
  use ExUnit.Case, async: true
  alias Linguistics.Lexicon
  alias Wordle.Strategy.Complements
  alias Wordle.Strategy.Compound
  alias Wordle.Strategy.Simple
  alias Wordle.Strategy.MissingGraphemes
  alias Wordle.Strategy.Random
  alias Wordle.Game

  @moduletag :integration
  @average [
    wordle: %{
      Compound => 3.76414686825054,
      Simple => 3.687257019438445,
      MissingGraphemes => 3.687257019438445,
      Complements => 1825
    },
    termo: %{
      Compound => 3.615902140672783,
      Simple => 3.6055045871559632,
      MissingGraphemes => 3.6055045871559632,
      Complements => 788
    }
  ]

  describe "Wordle.solve/3 with `complements` strategy" do
    test "succeeds 1825 times with wordle lexicon" do
      assert @average[:wordle][Complements] == count_successes("wordle", Complements)
    end

    test "succeeds 788 times with termo lexicon" do
      assert @average[:termo][Complements] == count_successes("termo", Complements)
    end
  end

  describe "Wordle.solve/3 with `simple` strategy" do
    test "solves all words in wordle dict with 8 or less attempts" do
      check_stats(:wordle, 8, Simple)
    end

    test "solves all words in termo dict with 9 or less attempts" do
      check_stats(:termo, 9, Simple)
    end
  end

  describe "Wordle.solve/3 with `compound` strategy" do
    test "solves all words in wordle dict with 8 or less attempts" do
      check_stats(:wordle, 8, Compound)
    end

    test "solves all words in termo dict with 8 or less attempts" do
      check_stats(:termo, 8, Compound)
    end
  end

  describe "Wordle.solve/3 with missing_graphemes strategy" do
    test "solves all words in wordle dict with 8 or less attempts" do
      check_stats(:wordle, 8, MissingGraphemes)
    end

    test "solves all words in termo dict with 9 or less attempts" do
      check_stats(:termo, 9, MissingGraphemes)
    end
  end

  describe "Wordle.solve/3 with random strategy" do
    test "solves all words in wordle dict with 10 or less attempts and is slower than simple strategy" do
      stats = full_dict_stats("wordle", 10, Random)

      assert average(stats) > @average[:wordle][Compound]
    end

    test "solves all words in termo dict with 10 or less attempts and is slower than simple strategy" do
      stats = full_dict_stats("termo", 10, Random)

      assert average(stats) > @average[:termo][Compound]
    end
  end

  @spec check_stats(atom(), integer(), module()) :: %{integer() => integer()}
  defp check_stats(lexicon, max_attempts, strategy) do
    stats = full_dict_stats(lexicon, max_attempts, strategy)
    assert stats |> Map.keys() |> Enum.max() == max_attempts
    assert average(stats) == @average[lexicon][strategy]
    stats
  end

  @spec full_dict_stats(String.t(), integer(), module()) :: %{integer() => integer()}
  defp full_dict_stats(dict_name, max_guesses, strategy) do
    lexicon = Lexicon.import(dict_name)

    lexicon
    |> Task.async_stream(
      fn right_word ->
        game = Game.new(lexicon, right_word)

        assert {:ok, game, _lexicon} = strategy.solve(lexicon, game),
               "Could not solve for #{right_word}."

        assert length(game.guesses) <= max_guesses,
               "Could not solve for #{right_word} in #{max_guesses} or less attempts."

        [word: right_word, guesses: length(game.guesses)]
      end,
      timeout: :infinity
    )
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.group_by(& &1[:guesses], & &1[:word])
    |> Enum.map(fn {n_guesses, words} -> {n_guesses, length(words)} end)
    |> Map.new()
  end

  @spec average(%{integer() => integer()}) :: float()
  defp average(stats) do
    total = stats |> Map.values() |> Enum.sum()

    stats
    |> Enum.reduce(0, fn {guesses, count}, acc ->
      acc + guesses * count
    end)
    |> Kernel./(total)
  end

  @spec count_successes(String.t(), module()) :: integer()
  defp count_successes(dict_name, strategy) do
    lexicon = Lexicon.import(dict_name)

    lexicon
    |> Task.async_stream(fn right_word ->
      game = Game.new(lexicon, right_word)
      strategy.solve(lexicon, game)
    end)
    |> Enum.map(fn {_status, result} -> result end)
    |> Enum.filter(fn {status, _game, _lexicon} -> status == :ok end)
    |> Enum.count()
  end
end
