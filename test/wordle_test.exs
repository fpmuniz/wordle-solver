defmodule WordleTest do
  use ExUnit.Case, async: true

  doctest Wordle

  describe "solve/2" do
    test "finds given word and returns ok" do
      words = ~w(easy here fret test heal deal feel yoga stay dont)
      assert {:ok, _guesses} = Wordle.solve(words, "dont")
    end

    test "keeps track of words tried before coming to the final solution" do
      words = ~w(easy here fret test heal deal feel yoga stay dont)
      assert {:ok, guesses} = Wordle.solve(words, "dont")
      assert ["dont", "easy"] = guesses
    end
  end
end
