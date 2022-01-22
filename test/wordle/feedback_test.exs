defmodule Wordle.FeedbackTest do
  use ExUnit.Case, async: true
  alias Wordle.Feedback

  describe "new/2" do
    test "creates a list of zeros" do
      assert %Feedback{acc: ~w(0 0 0 0)} = Feedback.new("test", "done")
    end

    test "counts graphemes in the right word" do
      assert %Feedback{counts: counts} = Feedback.new("test", "done")
      assert counts == %{"t" => 2, "e" => 1, "s" => 1}
    end
  end

  describe "exact_matches/1" do
    test "puts '2's into the correctly guessed graphemes positions" do
      feedback = Feedback.new("test", "temp")
      assert %Feedback{acc: acc} = Feedback.exact_matches(feedback)
      assert acc == ~w"2 2 0 0"
    end

    test "reduces the count of correctly guessed graphemes" do
      assert %{counts: counts} = feedback = Feedback.new("test", "temp")
      assert counts == %{"t" => 2, "e" => 1, "s" => 1}
      assert %Feedback{counts: counts} = Feedback.exact_matches(feedback)
      assert counts == %{"t" => 1, "e" => 0, "s" => 1}
    end

    test "resets position to 0 at the end" do
      feedback = Feedback.new("test", "temp")
      assert %Feedback{position: 0} = Feedback.exact_matches(feedback)
    end
  end

  describe "partial_matches/1" do
    test "puts '1's into the correctly guessed graphemes" do
      feedback = Feedback.new("test", "done")
      assert %Feedback{acc: acc} = Feedback.partial_matches(feedback)
      assert acc == ~w(0 0 0 1)
    end

    test "does not put '1' when the grapheme has already been guessed before" do
      feedback = Feedback.new("test", "exxe")
      assert %Feedback{acc: acc} = Feedback.partial_matches(feedback)
      assert acc == ~w(1 0 0 0 )
    end

    test "does not put '1' when the grapheme has been guessed before at right position" do
      feedback = "test" |> Feedback.new("eeee") |> Feedback.exact_matches()
      assert %Feedback{acc: acc} = Feedback.partial_matches(feedback)
      assert acc == ~w(0 2 0 0 )
    end

    test "puts multiple '1's when there is repetition in the right and guessed words" do
      feedback = "aaaaaa" |> Feedback.new("banana") |> Feedback.partial_matches()
      assert %Feedback{acc: acc} = feedback
      assert acc == ~w(0 1 0 1 0 1)
    end

    test "stops counting correct graphemes after all letter counts have been found" do
      feedback = "banana" |> Feedback.new("aaaaaa") |> Feedback.partial_matches()
      assert %Feedback{acc: acc} = feedback
      assert acc == ~w(1 1 1 0 0 0)
    end

    test "still counts letters when correct position guesses have been used and there's still more repetitions" do
      feedback =
        "banana"
        |> Feedback.new("aaaaax")
        |> Feedback.exact_matches()
        |> Feedback.partial_matches()

      assert %Feedback{acc: acc} = feedback
      assert acc == ~w(1 2 0 2 0 0)
    end
  end
end
