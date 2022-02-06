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
    test "returns a new game with a new feedback and latest guess included in its history" do
      word = "word"
      game = Game.new(~w(some word gone), word)
      expected_feedback = [:wrong, :correct, :wrong, :wrong]
      assert %Game{feedbacks: [^expected_feedback | _]} = game = Game.guess(game, "some")
      assert ["some" | _] = game.guesses
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
