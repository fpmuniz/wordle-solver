defmodule Wordle.StrategyTest do
  use ExUnit.Case, async: true

  alias Wordle.Strategy

  doctest Strategy

  # describe "feedback/2" do
  #   test "filters words that do not comply with given feedback" do
  #     lexicon = ~w(small ghost doing great scare)
  #     assert ["scare"] = Strategy.feedback(lexicon, "great", "01110")
  #   end

  #   test "uses first word on the list when a word isn't given" do
  #     lexicon = ~w(small ghost doing great scare)
  #     assert ["scare"] = Strategy.feedback(lexicon, "great", "01110")
  #   end
  # end
end
