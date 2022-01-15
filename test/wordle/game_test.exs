defmodule Wordle.GameTest do
  use ExUnit.Case, async: true
  alias Wordle.Game
  doctest Game

  describe "guess/2" do
    test "returns a string of 0, 1 and 2 as feedback for a guessed word" do
      word = "word"
      assert {guesses, "0200"} = Game.guess(word, "some")
      assert ["some"] = guesses
    end

    test "raises in case of length mismatch" do
      word = "word"

      assert_raise(ArgumentError, fn ->
        {_game, _feedback} = Game.guess(word, "invalid_word")
      end)
    end
  end
end
