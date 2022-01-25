defmodule IntegrationTest do
  use ExUnit.Case, async: true

  @moduletag :integration
  @compound_wordle_average 3.76414686825054
  @compound_termo_average 3.615902140672783

  describe "Wordle.solve/3 with complements strategy" do
    test "succeeds 1825 times with wordle lexicon" do
      assert 1825 == count_successes("wordle", :complements)
    end

    test "succeeds 788 times with temo lexicon" do
      assert 788 == count_successes("termo", :complements)
    end
  end

  describe "Wordle.solve/3 with simple strategy" do
    test "solves all words in wordle dict with 8 or less attempts" do
      stats = full_dict_stats("wordle", 8, :simple)

      assert stats == %{1 => 1, 2 => 127, 3 => 903, 4 => 945, 5 => 264, 6 => 57, 7 => 14, 8 => 4}
      assert average(stats) == 3.687257019438445
    end

    test "solves all words in termo dict with 9 or less attempts" do
      stats = full_dict_stats("termo", 9, :simple)

      assert stats == %{
               1 => 1,
               2 => 132,
               3 => 702,
               4 => 563,
               5 => 171,
               6 => 50,
               7 => 12,
               8 => 3,
               9 => 1
             }

      assert average(stats) == 3.6055045871559632
    end
  end

  describe "Wordle.solve/3 with compound strategy" do
    test "solves all words in wordle dict with 8 or less attempts" do
      stats = full_dict_stats("wordle", 9, :compound)

      assert stats == %{1 => 1, 2 => 128, 3 => 857, 4 => 839, 5 => 425, 6 => 54, 7 => 7, 8 => 4}
      assert average(stats) == @compound_wordle_average
    end

    test "solves all words in termo dict with 9 or less attempts" do
      stats = full_dict_stats("termo", 9, :compound)

      assert stats == %{1 => 1, 2 => 132, 3 => 655, 4 => 612, 5 => 186, 6 => 41, 7 => 6, 8 => 2}
      assert average(stats) == @compound_termo_average
    end
  end

  describe "Wordle.solve/3 with random strategy" do
    test "solves all words in wordle dict with 10 or less attempts and is slower than simple strategy" do
      stats = full_dict_stats("wordle", 10, :random)

      assert average(stats) > @compound_wordle_average
    end

    test "solves all words in termo dict with 10 or less attempts and is slower than simple strategy" do
      stats = full_dict_stats("termo", 10, :random)

      assert average(stats) > @compound_termo_average
    end
  end

  @spec full_dict_stats(String.t(), integer(), atom()) :: %{integer() => integer()}
  defp full_dict_stats(dict_name, max_guesses, strategy) do
    words = Lexicon.import(dict_name)

    words
    |> Task.async_stream(fn right_word ->
      assert {:ok, guesses} = Wordle.Strategy.solve(words, right_word, strategy),
             "Could not solve for #{right_word}."

      assert length(guesses) <= max_guesses,
             "Could not solve for #{right_word} in #{max_guesses} or less attempts."

      [word: right_word, guesses: length(guesses)]
    end)
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
