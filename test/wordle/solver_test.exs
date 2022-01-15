defmodule Wordle.SolverTest do
  use ExUnit.Case, async: true

  alias Wordle.Solver

  doctest Solver

  describe "feedback/2" do
    test "filters words that do not comply with given feedback" do
      words = ~w(small ghost doing great scare)
      assert ["scare"] = Solver.feedback(words, "great", "01110")
    end

    test "uses first word on the list when a word isn't given" do
      words = ~w(small ghost doing great scare)
      assert ["scare"] = Solver.feedback(words, "20200")
    end
  end

  describe "complement/2" do
    test "returns a list of words which does not contain letters from last guess" do
      words = ~w(small ghost doing great scare)
      assert ["small", "scare"] = Solver.complement(words, "doing")
    end
  end
end
