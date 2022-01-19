defmodule IntegrationTest do
  use ExUnit.Case, async: true

  @moduletag :integration
  @moduletag timeout: :infinity

  describe "Wordle.solve/2" do
    test "solves all words in wordle dict" do
      stats = full_dict_stats("wordle", 8)
      assert stats == %{1 => 1, 2 => 127, 3 => 903, 4 => 945, 5 => 263, 6 => 58, 7 => 14, 8 => 4}
      assert average(stats) == 3.6876889848812096
    end

    test "solves all words in termo dict" do
      stats = full_dict_stats("termo", 9)

      assert stats == %{
               1 => 1,
               2 => 132,
               3 => 701,
               4 => 564,
               5 => 171,
               6 => 50,
               7 => 12,
               8 => 3,
               9 => 1
             }

      assert average(stats) == 3.6061162079510702
    end
  end

  @spec full_dict_stats(binary, integer) :: %{integer => integer}
  defp full_dict_stats(dict_name, max_guesses) do
    words = Parser.import_dictionary(dict_name)

    words
    |> Enum.map(fn right_word ->
      Task.async(fn ->
        assert {:ok, guesses} = Wordle.solve(words, right_word),
               "Could not solve for #{right_word}."

        assert length(guesses) <= max_guesses,
               "Could not solve for #{right_word} in #{max_guesses} or less attempts."

        {right_word, length(guesses)}
      end)
    end)
    |> Task.await_many(:infinity)
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
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
