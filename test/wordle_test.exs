defmodule WordleTest do
  use ExUnit.Case, async: true
  doctest Wordle

  setup :wordle

  describe "wrong_letter/2" do
    test "removes words that contain a given letter", %{wordle: wordle} do
      assert %Wordle{words: words} = Wordle.wrong_letter(wordle, "e")
      assert words == ~w(stay yoga dont)
    end
  end

  describe "wrong_position/3" do
    test "keeps only words that contain a given letter", %{wordle: wordle} do
      assert %Wordle{words: words} = Wordle.wrong_position(wordle, "e", 3)
      assert words == ~w(easy deal heal fret test feel)
    end

    test "removes words that contain given letter in wrong position", %{wordle: wordle} do
      assert %Wordle{words: words} = Wordle.wrong_position(wordle, "e", 1)
      assert words == ~w(easy fret)
    end
  end

  describe "right_position/3" do
    test "keeps only words that contain given letter at exact given position", %{wordle: wordle} do
      assert %Wordle{words: words} = Wordle.right_position(wordle, "e", 1)
      assert words == ~w(deal heal test feel here)
    end
  end

  describe "solve/2" do
    test "finds given word and records attempts", %{wordle: wordle} do
      assert {:ok, wordle} = Wordle.solve(wordle, "dont")
      assert ["dont" | _] = wordle.suggestions
    end
  end

  defp wordle(context) do
    words = ~w(easy here fret test heal deal feel yoga stay dont)
    wordle = Wordle.new(words)

    Map.put(context, :wordle, wordle)
  end
end
