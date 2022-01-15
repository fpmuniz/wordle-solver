defmodule IntegrationTest do
  use ExUnit.Case, async: true

  @max_attempts 11
  @letter_count 5
  @moduletag :integration

  setup :wordlist

  describe "Wordle.solve/2" do
    test "solves every case in less than #{@max_attempts} attempts", %{words: words} do
      words
      |> Enum.with_index()
      |> Enum.each(fn {right_word, index} ->
        assert {:ok, guesses} = Wordle.solve(words, right_word),
               "Could not solve for #{right_word} at position #{index}."

        assert length(guesses) <= @max_attempts,
               "Expected to succeed with less than #{@max_attempts} attempts, got [#{guesses |> Enum.join(", ")}]. Failed with word #{right_word} at position #{index}."
      end)
    end
  end

  defp wordlist(context) do
    words =
      "dicts/pt_br.txt"
      |> Parser.import_dictionary()
      |> Parser.trim()
      |> Language.normalize(:pt_br)
      |> Parser.filter_number_of_letters(@letter_count)
      |> Parser.filter_valid()
      |> WordStats.order_by_scores()

    context
    |> Map.put(:words, words)
  end
end
