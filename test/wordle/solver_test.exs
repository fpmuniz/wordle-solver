defmodule Wordle.SolverTest do
  use ExUnit.Case, async: true

  alias Wordle.Solver

  doctest Solver

  describe "feedback/2" do
    test "filters words that do not comply with given feedback" do
      solver = Solver.new(~w(small ghost doing great scare))
      assert solver = %Solver{} = Solver.feedback(solver, "great", "01110")
      assert solver.wordlist == ["scare"]
    end

    test "uses first word on the list when a word isn't given" do
      solver = Solver.new(~w(small ghost doing great scare))
      assert solver = %Solver{} = Solver.feedback(solver, "great", "01110")
      assert solver.wordlist == ["scare"]
    end
  end
end
