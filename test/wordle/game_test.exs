defmodule Wordle.GameTest do
  use ExUnit.Case, async: true

  alias Wordle.Game

  describe "new/2" do
    test "generates a new game" do
      assert %Game{} = Game.new(~w(some word gone), "some")
    end

    test "returns an error when right_word isn't in the list" do
      assert_raise ArgumentError, fn -> Game.new(~w(some word gone), "invalid") end
    end
  end

  describe "guess/2" do
    test "returns a string of 0, 1 and 2 as feedback for a guessed word" do
      word = "word"
      game = Game.new(~w(some word gone), word)
      assert %Game{feedbacks: ["0200" | _]} = game = Game.guess(game, "some")
      assert ["some"] = game.guesses
    end

    test "raises in case of length mismatch" do
      word = "word"
      game = Game.new(~w(some word gone), word)

      assert_raise(ArgumentError, fn ->
        {_game, _feedback} = Game.guess(game, "invalid_word")
      end)
    end
  end
end
