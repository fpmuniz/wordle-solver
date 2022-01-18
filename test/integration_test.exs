defmodule IntegrationTest do
  use ExUnit.Case, async: true

  @language :pt_br
  @letter_count 5
  @moduletag :integration
  @moduletag timeout: :infinity

  setup :wordlist

  describe "Wordle.solve/2" do
    test "solves in an average number of guesses", %{words: words} do
      solved =
        words
        |> Enum.with_index()
        |> Enum.map(fn {right_word, index} ->
          Task.async(fn ->
            assert {:ok, guesses} = Wordle.solve(words, right_word),
                   "Could not solve for #{right_word} at position #{index}."

            {right_word, length(guesses)}
          end)
        end)
        |> Task.await_many(:infinity)
        |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
        |> Enum.map(fn {n_guesses, words} -> {n_guesses, length(words)} end)
        |> Map.new()

      average =
        Enum.reduce(solved, 0, fn {guesses, count}, acc -> acc + guesses * count end) /
          length(words)

      assert average == 4.0650467289719625

      assert solved == %{
               1 => 1,
               2 => 185,
               3 => 1574,
               4 => 2088,
               5 => 980,
               6 => 335,
               7 => 125,
               8 => 47,
               9 => 10,
               10 => 3,
               11 => 2
             }
    end
  end

  defp wordlist(context) do
    words = Wordle.import(@language, @letter_count)

    context
    |> Map.put(:words, words)
  end
end
