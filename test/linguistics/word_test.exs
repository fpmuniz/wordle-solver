defmodule Linguistics.WordTest do
  use ExUnit.Case, async: true
  alias Linguistics.Word

  describe "uniq/1" do
    test "returns only unique graphemes as a word" do
      assert Word.uniq("aaaabbcc") == "abc"
    end
  end

  describe "reduce/3" do
    test "correctly reduces a word into a sum of its graphemes values" do
      values = %{"a" => 1, "b" => 2, "c" => 4}

      assert Word.reduce("abc", 0, fn grapheme, acc ->
               acc + values[grapheme]
             end) == 7
    end
  end

  describe "score/2" do
    grapheme_scores = %{"w" => 10, "o" => 20, "r" => 5, "d" => 1}
    assert 36 = Word.score("word", grapheme_scores)
  end

  describe "valid?/2" do
    test "returns true to a valid english word" do
      valid_graphemes = ~w(e h l o)
      assert Word.valid?("hello", valid_graphemes)
    end

    test "returns false to an invalid english word" do
      valid_graphemes = ~w(a b c)
      refute Word.valid?("こんにちは", valid_graphemes)
    end
  end

  describe "counts/1" do
    test "returns a map of graphemes with their respective frequencies" do
      assert %{"g" => 5, "b" => 2} = Word.counts("gggggbb")
    end
  end
end
