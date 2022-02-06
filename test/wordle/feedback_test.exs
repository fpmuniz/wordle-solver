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

  # describe "maxmin/2" do
  #   test "works as expected when there is no grapheme repetition" do
  #     # right word: 'words'; guessed word: 'dwarf'

  #     counts = Feedback.maxmin("dwarf", "11010")
  #     assert counts["d"] == [max: 5, min: 1]
  #     assert counts["w"] == [max: 5, min: 1]
  #     assert counts["a"] == [max: 0, min: 0]
  #     assert counts["r"] == [max: 5, min: 1]
  #     assert counts["f"] == [max: 0, min: 0]
  #   end

  #   test "sets minimum count to # of graphemes repeated in guessed word" do
  #     # right word: 'bobby'; guessed word: 'booby'

  #     counts = Feedback.maxmin("booby", "22022")
  #     assert counts["b"] == [max: 5, min: 2]
  #     assert counts["o"] == [max: 1, min: 1]
  #     assert counts["y"] == [max: 5, min: 1]
  #   end

  #   test "sets maximum count to # of graphemes repeated in guessed word when exceeding" do
  #     # right word: 'booby'; guessed word: 'bobby'

  #     counts = Feedback.maxmin("bobby", "22022")
  #     assert counts["b"] == [max: 2, min: 2]
  #     assert counts["o"] == [max: 5, min: 1]
  #     assert counts["y"] == [max: 5, min: 1]
  #   end
  # end

  describe "feedback/2" do
    test "filters words that do not comply with given feedback" do
      lexicon = ~w(small ghost doing great scare)
      feedback = [:wrong, :misplaced, :misplaced, :misplaced, :wrong]

      assert ["scare"] = Feedback.filter(lexicon, "great", feedback)
    end

    test "uses first word on the list when a word isn't given" do
      lexicon = ~w(small ghost doing great scare)
      feedback = [:wrong, :misplaced, :misplaced, :misplaced, :wrong]
      assert ["scare"] = Feedback.filter(lexicon, "great", feedback)
    end
  end
end
