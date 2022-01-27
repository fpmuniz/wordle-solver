defmodule IntegrationTest do
  alias Linguistics.Lexicon
  use ExUnit.Case, async: true

  @moduletag :integration
  @average [
    wordle: [
      compound: 3.76414686825054,
      simple: 3.687257019438445,
      missing_graphemes: 3.687257019438445,
      complements: 1825
    ],
    termo: [
      compound: 3.615902140672783,
      simple: 3.6055045871559632,
      missing_graphemes: 3.6055045871559632,
      complements: 788
    ]
  ]

  describe "Wordle.solve/3 with `complements` strategy" do
    test "succeeds 1825 times with wordle lexicon" do
      assert @average[:wordle][:complements] == count_successes("wordle", :complements)
    end

    test "succeeds 788 times with termo lexicon" do
      assert @average[:termo][:complements] == count_successes("termo", :complements)
    end
  end

  describe "Wordle.solve/3 with `simple` strategy" do
    test "solves all words in wordle dict with 8 or less attempts" do
      check_stats(:wordle, 8, :simple)
    end

    test "solves all words in termo dict with 9 or less attempts" do
      check_stats(:termo, 9, :simple)
    end
  end

  describe "Wordle.solve/3 with `compound` strategy" do
    test "solves all words in wordle dict with 8 or less attempts" do
      check_stats(:wordle, 8, :compound)
    end

    test "solves all words in termo dict with 8 or less attempts" do
      check_stats(:termo, 8, :compound)
    end
  end

  describe "Wordle.solve/3 with missing_graphemes strategy" do
    test "solves all words in wordle dict with 8 or less attempts" do
      check_stats(:wordle, 8, :missing_graphemes)
    end

    test "solves all words in termo dict with 9 or less attempts" do
      check_stats(:termo, 9, :missing_graphemes)
    end
  end

  describe "Wordle.solve/3 with random strategy" do
    test "solves all words in wordle dict with 10 or less attempts and is slower than simple strategy" do
      stats = full_dict_stats("wordle", 10, :random)

      assert average(stats) > @average[:wordle][:compound]
    end

    test "solves all words in termo dict with 10 or less attempts and is slower than simple strategy" do
      stats = full_dict_stats("termo", 10, :random)

      assert average(stats) > @average[:termo][:compound]
    end
  end

  @spec check_stats(atom(), integer(), atom()) :: %{integer() => integer()}
  defp check_stats(lexicon, max_attempts, strategy) do
    stats = full_dict_stats(lexicon, max_attempts, strategy)
    assert stats |> Map.keys() |> Enum.max() == max_attempts
    assert average(stats) == @average[lexicon][strategy]
    stats
  end

  @spec full_dict_stats(String.t(), integer(), atom()) :: %{integer() => integer()}
  defp full_dict_stats(dict_name, max_guesses, strategy) do
    words = Lexicon.import(dict_name)

    words
    |> Task.async_stream(
      fn right_word ->
        assert {:ok, guesses} = Wordle.Strategy.solve(words, right_word, strategy),
               "Could not solve for #{right_word}."

        assert length(guesses) <= max_guesses,
               "Could not solve for #{right_word} in #{max_guesses} or less attempts."

        [word: right_word, guesses: length(guesses)]
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

  @spec count_successes(String.t(), atom()) :: integer()
  defp count_successes(dict_name, strategy) do
    lexicon = Lexicon.import(dict_name)

    lexicon
    |> Task.async_stream(fn right_word ->
      Wordle.Strategy.solve(lexicon, right_word, strategy)
    end)
    |> Enum.map(fn {_status, result} -> result end)
    |> Enum.filter(fn {status, _guesses} -> status == :ok end)
    |> Enum.count()
  end
end
