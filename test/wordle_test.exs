defmodule WordleTest do
  use ExUnit.Case
  doctest Wordle

  setup :wordle

  describe "suggest/1" do
    test "returns the first word on the list", %{wordle: wordle} do
      assert Wordle.suggest(wordle) == "easy"
    end
  end

  describe "wrong_letter/2" do
    test "removes words that contain a given letter", %{wordle: wordle} do
      assert %Wordle{words: words} = Wordle.wrong_letter(wordle, "e")
      assert words == ~w(yoga stay dont)
    end
  end

  describe "wrong_position/3" do
    test "keeps only words that contain a given letter", %{wordle: wordle} do
      assert %Wordle{words: words} = Wordle.wrong_position(wordle, "e", 3)
      assert words == ~w(easy fret test heal deal feel)
    end

    test "removes words that contain given letter in wrong position", %{wordle: wordle} do
      assert %Wordle{words: words} = Wordle.wrong_position(wordle, "e", 1)
      assert words == ~w(easy fret)
    end
  end

  describe "right_position/3" do
    test "keeps only words that contain given letter at exact given position", %{wordle: wordle} do
      assert %Wordle{words: words} = Wordle.right_position(wordle, "e", 1)
      assert words == ~w(here test heal deal feel)
    end
  end

  defp wordle(context) do
    words = ~w(easy here fret test heal deal feel yoga stay dont)
    wordle = %Wordle{words: words}

    Map.put(context, :wordle, wordle)
  end
end
