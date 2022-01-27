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

  describe "valid?/2" do
    test "returns true to a valid english word" do
      assert Word.valid?("hello", :en)
    end

    test "returns false to an invalid english word" do
      refute Word.valid?("こんにちは", :en)
    end
  end
end
