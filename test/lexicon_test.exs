defmodule LexiconTest do
  alias Linguistics.Lexicon
  use ExUnit.Case, async: true

  describe "filter_by_length/1" do
    test "only returns 5 letter words" do
      words = ~w(do you wanna see five letter words now)
      assert Lexicon.filter_by_length(words, 5) == ~w(wanna words)
    end
  end

  describe "downcase/1" do
    test "converts strings to lowercase" do
      words = ~w(SOME WorDS caN be IrReGULAR)
      assert Lexicon.downcase(words) == ~w(some words can be irregular)
    end
  end

  describe "trim/1" do
    test "removes whitespace from words" do
      words = ["   padding  "]
      assert Lexicon.trim(words) == ["padding"]
    end
  end

  describe "filter_valid/1" do
    test "removes words with uppercase letters" do
      words = ~w(Texas AC DC hello)
      assert Lexicon.filter_valid(words) == ~w(hello)
    end

    test "removes words with symbols" do
      words = ~w(don't can't st. valid word)
      assert Lexicon.filter_valid(words) == ~w(valid word)
    end
  end
end
