defmodule Wordle.Feedback.ReceiverTest do
  use ExUnit.Case, async: true
  alias Wordle.Feedback.Receiver

  describe "maxmin/2" do
    test "works as expected when there is no grapheme repetition" do
      # right word: 'words'; guessed word: 'dwarf'

      response = [:misplaced, :misplaced, :wrong, :misplaced, :wrong]
      counts = Receiver.maxmin("dwarf", response)
      assert counts["d"] == [max: 5, min: 1]
      assert counts["w"] == [max: 5, min: 1]
      assert counts["a"] == [max: 0, min: 0]
      assert counts["r"] == [max: 5, min: 1]
      assert counts["f"] == [max: 0, min: 0]
    end

    test "sets minimum count to # of correct graphemes repeated in guessed word" do
      # right word: 'bobby'; guessed word: 'booby'

      response = [:correct, :correct, :wrong, :correct, :correct]
      counts = Receiver.maxmin("booby", response)
      assert counts["b"] == [max: 5, min: 2]
      assert counts["o"] == [max: 1, min: 1]
      assert counts["y"] == [max: 5, min: 1]
    end

    test "sets maximum count to # of correct graphemes repeated in guessed word when exceeding" do
      # right word: 'booby'; guessed word: 'bobby'

      response = [:correct, :correct, :wrong, :correct, :correct]
      counts = Receiver.maxmin("bobby", response)
      assert counts["b"] == [max: 2, min: 2]
      assert counts["o"] == [max: 5, min: 1]
      assert counts["y"] == [max: 5, min: 1]
    end
  end
end
