defmodule Wordle.Feedback.BuilderTest do
  use ExUnit.Case, async: true
  alias Wordle.Feedback.Builder

  describe "new/2" do
    test "returns a struct at position 0" do
      assert %Builder{position: 0} = Builder.new("word", "some")
    end

    test "returns a struct that contains the right word" do
      assert %Builder{right_word: "word"} = Builder.new("word", "some")
    end

    test "returns a struct containing the count for each grapheme in the right word" do
      counts = %{"w" => 1, "o" => 1, "r" => 1, "d" => 1}
      assert %Builder{counts: ^counts} = Builder.new("word", "some")
    end

    test "returns a struct containing the guessed word" do
      assert %Builder{guessed_word: "some"} = Builder.new("word", "some")
    end

    test "returns a struct containing the right word length" do
      assert %Builder{size: 4} = Builder.new("word", "some")
    end

    test "starts accumulating the classifications in a list that assumes all graphemes are wrong" do
      assert %Builder{acc: [:wrong, :wrong, :wrong, :wrong]} = Builder.new("word", "some")
    end
  end

  describe "exact_matches/1" do
    test "finds all graphemes that are in the right position" do
      builder =
        "word"
        |> Builder.new("some")
        |> Builder.exact_matches()

      assert builder.acc == [:wrong, :correct, :wrong, :wrong]
    end

    test "resets position to 0 after reaching the end of the word" do
      builder = %Builder{size: 4, position: 4}

      assert %Builder{position: 0} = Builder.exact_matches(builder)
    end
  end

  describe "partial_matches/1" do
    test "classifies any grapheme in the word as misplaced, if it hasn't been found before" do
      feedback = [:wrong, :misplaced, :wrong, :wrong]
      builder = Builder.new("word", "some")

      assert %Builder{acc: ^feedback} = Builder.partial_matches(builder)
    end

    test "does not classify an extra grapheme that is more frequent in guess than in right word" do
      feedback = [:misplaced, :misplaced, :wrong, :wrong]
      builder = Builder.new("wood", "oooo")

      assert %Builder{acc: ^feedback} = Builder.partial_matches(builder)
    end

    test "resets position to 0 after reaching the end of the word" do
      builder = %Builder{size: 4, position: 4}

      assert %Builder{position: 0} = Builder.partial_matches(builder)
    end
  end

  describe "get_result/1" do
    test "returns the accumulated feedback as a list of classification atoms" do
      feedback = [:misplaced, :right, :wrong, :misplaced]
      builder = %Builder{acc: feedback}
      assert ^feedback = Builder.get_result(builder)
    end
  end
end
