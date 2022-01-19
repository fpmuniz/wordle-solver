defmodule IntegrationTest do
  use ExUnit.Case, async: true

  @moduletag :integration
  @moduletag timeout: :infinity

  describe "Wordle.solve/2" do
    test "solves all words in wordle dict" do
      stats = full_dict_stats("wordle", 8)

      assert stats == %{1 => 1, 2 => 128, 3 => 857, 4 => 839, 5 => 425, 6 => 54, 7 => 7, 8 => 4}
      assert average(stats) == 3.76414686825054
    end

    test "solves all words in termo dict" do
      stats = full_dict_stats("termo", 8)

      assert stats == %{1 => 1, 2 => 132, 3 => 655, 4 => 612, 5 => 185, 6 => 42, 7 => 6, 8 => 2}
      assert average(stats) == 3.61651376146789
    end
  end

  @spec full_dict_stats(binary, integer) :: %{integer => integer}
  defp full_dict_stats(dict_name, max_guesses) do
    words = Wordle.from_dict(dict_name).wordlist

    words
    |> Task.async_stream(fn right_word ->
      assert {:ok, guesses} = Wordle.solve(words, right_word),
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

  @spec average(%{integer => integer}) :: float
  defp average(stats) do
    total = stats |> Map.values() |> Enum.sum()

    stats
    |> Enum.reduce(0, fn {guesses, count}, acc ->
      acc + guesses * count
    end)
    |> Kernel./(total)
  end
end
