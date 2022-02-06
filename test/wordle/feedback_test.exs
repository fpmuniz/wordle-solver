defmodule Wordle.FeedbackTest do
  use ExUnit.Case, async: true
  alias Wordle.Feedback

  describe "build/2" do
    test "puts :correct into the correctly guessed graphemes positions" do
      assert [:correct, :correct, :wrong, :wrong] = Feedback.build("test", "temp")
    end

    test "maintains the correct count of letters" do
      assert [:correct, :correct, :misplaced, :misplaced] = Feedback.build("test", "tets")
    end

    test "puts :misplaced into the existing graphemes that are out of position" do
      assert [:wrong, :wrong, :wrong, :misplaced] = Feedback.build("test", "done")
    end

    test "does not put :misplaced when the grapheme has already been guessed before" do
      assert [:misplaced, :wrong, :wrong, :wrong] = Feedback.build("test", "exxe")
    end

    test "does not put :misplaced when the grapheme has been guessed before at right position" do
      assert [:wrong, :correct, :wrong, :wrong] = Feedback.build("test", "eeee")
    end

    test "puts multiple :misplaced when there is repetition in the right and guessed words" do
      assert [:misplaced, :misplaced, :wrong, :misplaced, :wrong, :misplaced] =
               Feedback.build("ababab", "banana")
    end

    test "stops counting correct graphemes after all letter counts have been found" do
      assert [:misplaced, :misplaced, :wrong, :wrong, :wrong, :wrong] =
               Feedback.build("bbbaac", "aaaxxx")
    end

    test "still counts letters when correct position guesses have been used and there's still more repetitions" do
      assert [:misplaced, :correct, :wrong, :correct, :wrong, :wrong] =
               Feedback.build("banana", "aaaaax")
    end
  end

  describe "filter/2" do
    test "filters words that do not comply with given feedback" do
      lexicon = ~w(small ghost doing great scare)
      feedback = [:wrong, :misplaced, :misplaced, :misplaced, :wrong]

      assert ["scare"] = Feedback.filter(lexicon, "great", feedback)
    end

    test "uses first word on the list when a word isn't given" do
      lexicon = ~w(small ghost doing great scare)
      feedback = [:correct, :wrong, :correct, :wrong, :wrong]
      assert ["scare"] = Feedback.filter(lexicon, feedback)
    end

    test "does nothing to an empty list" do
      lexicon = []
      feedback = [:correct, :correct, :wrong, :misplaced]
      assert [] = Feedback.filter(lexicon, feedback)
    end
  end
end
