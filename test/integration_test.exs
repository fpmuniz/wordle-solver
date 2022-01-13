defmodule IntegrationTest do
  use ExUnit.Case, async: true

  @max_attempts 12
  @letter_count 4
  @moduletag :integration

  setup :wordle

  describe "Wordle.solve/2" do
    test "solves every case in less than #{@max_attempts} attempts", %{wordle: wordle} do
      wordle.words
      |> Enum.with_index()
      |> Enum.each(fn {right_word, index} ->
        assert {:ok, %Wordle{suggestions: attempts}} = Wordle.solve(wordle, right_word),
               "Could not solve for #{right_word} at position #{index}."

        assert length(attempts) <= @max_attempts,
               "Expected to succeed with less than #{@max_attempts} attempts, got [#{attempts |> Enum.join(", ")}]. Failed with word #{right_word} at position #{index}."
      end)
    end
  end

  defp wordle(context) do
    wordle =
      "dicts/pt_br.txt"
      |> Wordle.import_words(:pt_br)
      |> Enum.filter(&(String.length(&1) == @letter_count))
      |> Wordle.new()

    context
    |> Map.put(:wordle, wordle)
  end
end
