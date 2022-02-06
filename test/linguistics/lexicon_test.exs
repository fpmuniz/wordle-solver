defmodule Linguistics.LexiconTest do
  use ExUnit.Case, async: true
  alias Linguistics.Lexicon

  describe "grapheme_frequencies/1" do
    test "returns frequencies in percentage" do
      words = ~w(abcd ab ab)

      assert Lexicon.grapheme_frequencies(words) == %{
               "a" => 3,
               "b" => 3,
               "c" => 1,
               "d" => 1
             }
    end
  end

  describe "order_by_scores/1" do
    test "rearranges lexicon by calculating scores by itself when not provided" do
      lexicon = ~w(done come mice)
      assert ~w(come mice done) == Lexicon.order_by_scores(lexicon)
    end
  end

  describe "order_by_scores/2" do
    test "calculates each word's score and orders the words in descending score order" do
      scores = %{"a" => 5, "b" => 2, "c" => 1}
      words = ~w(bc ab abc c a b)

      assert Lexicon.order_by_scores(words, scores) == ~w(abc ab a bc b c)
    end

    test "ignores repeated letters when calculating scores" do
      scores = %{"a" => 5, "b" => 2, "c" => 1}
      words = ["abc", "bbbbbcc"]

      assert Lexicon.order_by_scores(words, scores) == ["abc", "bbbbbcc"]
    end
  end

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
      lowercase = ?a..?z |> Enum.to_list() |> List.to_string() |> String.codepoints()
      assert Lexicon.filter_valid(words, lowercase) == ~w(hello)
    end

    test "removes words with symbols" do
      words = ~w(don't can't st. valid word)
      valid_graphemes = ?a..?z |> Enum.to_list() |> List.to_string() |> String.codepoints()
      assert Lexicon.filter_valid(words, valid_graphemes) == ~w(valid word)
    end
  end

  describe "import/1" do
    test "successfully imports a list of words from a given lexicon name" do
      lexicon = Lexicon.import("test")
      assert is_list(lexicon)
    end
  end

  describe "write/2" do
    test "writes a list of words into a file" do
      lexicon = ~w(done come mice)
      assert :ok = Lexicon.export(lexicon, "tmp")
      assert :ok = File.rm!("lib/linguistics/lexicon/tmp.txt")
    end
  end
end
