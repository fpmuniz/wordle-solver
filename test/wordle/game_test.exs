defmodule Wordle.GameTest do
  use ExUnit.Case, async: true

  alias Wordle.Game

  describe "new/2" do
    test "generates a new game" do
      assert %Game{} = Game.new(~w(some word gone), "some")
    end

    test "returns an error when right_word isn't in the list" do
      assert_raise Game.NotInWordList, fn -> Game.new(~w(some word gone), "invalid") end
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

      assert_raise(Game.NotInWordList, fn ->
        {_game, _feedback} = Game.guess(game, "invalid_word")
      end)
    end
  end

  describe "update_status/2" do
    test "does not downgrade a correct grapheme's status" do
      assert :correct = Game.update_status(:correct, :unknown)
      assert :correct = Game.update_status(:correct, :wrong)
      assert :correct = Game.update_status(:correct, :misplaced)
    end

    test "does not downgrade a misplaced grapheme's status" do
      assert :misplaced = Game.update_status(:misplaced, :unknown)
      assert :misplaced = Game.update_status(:misplaced, :wrong)
      assert :correct = Game.update_status(:misplaced, :correct)
    end

    test "does not change a wrong grapheme's status" do
      assert :wrong = Game.update_status(:wrong, :unknown)
      assert :wrong = Game.update_status(:wrong, :misplaced)
      assert :wrong = Game.update_status(:wrong, :correct)
    end

    test "always changes an unknown grapheme's status" do
      assert :wrong = Game.update_status(:unknown, :wrong)
      assert :misplaced = Game.update_status(:unknown, :misplaced)
      assert :correct = Game.update_status(:unknown, :correct)
    end
  end
end
