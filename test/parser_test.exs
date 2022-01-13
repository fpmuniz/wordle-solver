defmodule ParserTest do
  use ExUnit.Case, async: true
  doctest Parser

  @moduletag :wip

  describe "filter_number_of_letters/1" do
    test "only returns 5 letter words" do
      words = ~w(do you wanna see five letter words now)
      assert Parser.filter_number_of_letters(words, 5) == ~w(wanna words)
    end
  end

  describe "downcase/1" do
    test "converts strings to lowercase" do
      words = ~w(SOME WorDS caN be IrReGULAR)
      assert Parser.downcase(words) == ~w(some words can be irregular)
    end
  end

  describe "trim/1" do
    test "removes whitespace from words" do
      words = ["   padding  "]
      assert Parser.trim(words) == ["padding"]
    end
  end

  describe "filter_valid/1" do
    test "removes words with uppercase letters" do
      words = ~w(Texas AC DC hello)
      assert Parser.filter_valid(words) == ~w(hello)
    end

    test "removes words with symbols" do
      words = ~w(don't can't st. valid word)
      assert Parser.filter_valid(words) == ~w(valid word)
    end
  end
end
