defmodule ScoreTest do
  use ExUnit.Case, async: true
  doctest Score

  describe "letter_frequencies/1" do
    test "returns frequencies in percentage" do
      words = ~w(abcd ab ab)

      assert Score.letter_frequencies(words) == %{
               "a" => 3,
               "b" => 3,
               "c" => 1,
               "d" => 1
             }
    end
  end

  describe "order_by_scores/2" do
    test "calculates each word's score and orders the words in descending score order" do
      scores = %{"a" => 5, "b" => 2, "c" => 1}
      words = ~w(bc ab abc c a b)

      assert Score.order_by_scores(words, scores) == ~w(abc ab a bc b c)
    end

    test "ignores repeated letters when calculating scores" do
      scores = %{"a" => 5, "b" => 2, "c" => 1}
      words = ["abc", "bbbbbcc"]

      assert Score.order_by_scores(words, scores) == ["abc", "bbbbbcc"]
    end
  end
end
