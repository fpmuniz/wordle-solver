defmodule Wordle.Strategy.MaxMinGraphTest do
  use ExUnit.Case, async: true
  alias Wordle.Strategy.MaxMinGraph
  alias Wordle.Feedback
  alias Wordle.Game

  describe "all_possible_feedbacks/1" do
    test "shows all permutations of feedback classifications" do
      permutations = MaxMinGraph.all_possible_feedbacks(5)

      assert length(permutations) == :math.pow(3, 5)
    end
  end

  describe "lexicon_size_after_filtering/3" do
    test "returns number of valid words after feedback has been interpreted" do
      lexicon = ~w(word size give take done gone)
      guess = "give"
      right_word = "gone"
      feedback = Feedback.build(right_word, guess)

      assert 1 == MaxMinGraph.lexicon_size_after_filtering(lexicon, guess, feedback)
    end
  end

  describe "worst_feedback_lexicon_size/3" do
    test "returns biggest size of lexicon given the worst-case scenario feedback" do
      lexicon = ~w(word size give take done gone)
      word_size = 4
      feedbacks = MaxMinGraph.all_possible_feedbacks(word_size)

      assert 3 = MaxMinGraph.worst_feedback_lexicon_size(lexicon, "word", feedbacks)
    end
  end

  describe "sort/1" do
    test "returns words in order of best to worst suggestions" do
      lexicon = ~w(word size give take done gone)
      word_size = 4
      sorted = ["give", "gone", "word", "size", "done", "take"]

      assert ^sorted = MaxMinGraph.sort(lexicon, word_size)
    end
  end

  describe "solve/2" do
    test "solves a simple game with a small number of words" do
      lexicon = ~w(word size give take done gone) |> MaxMinGraph.sort()
      game = Game.new(lexicon, "word")

      assert {:ok, game, _lexicon} = MaxMinGraph.solve(lexicon, game)
      assert ["word", "give"] = game.guesses
    end
  end
end
