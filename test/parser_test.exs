defmodule ParserTest do
  use ExUnit.Case
  doctest Parser

  describe "parse_words/1" do
    test "sorts an unsorted wordlist" do
      words = ~w(some words are unsorted)
      assert Parser.parse_words(words) == ~w(are some unsorted words)
    end

    test "converts strings to lowercase" do
      words = ~w(SOME WorDS caN be IrReGULAR)
      assert Parser.parse_words(words) == ~w(be can irregular some words)
    end
  end
end
