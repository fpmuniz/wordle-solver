defmodule LanguageTest do
  alias Linguistics.Language
  use ExUnit.Case, async: true

  describe "normalize/2" do
    test "removes accents words" do
      words = ["áâàãçéêíóôõúÁÂÀÃÇÉÊÍÓÔÕÚ"]
      assert Language.normalize(words, :pt_br) == ["aaaaceeiooouAAAACEEIOOOU"]
    end

    test "does not change unaccented letters" do
      words =
        ?A..?z
        |> Enum.to_list()
        |> to_string()
        |> String.graphemes()

      assert Language.normalize(words, :pt_br) == words
    end

    test "raises an error when given language is not supported" do
      assert_raise(ArgumentError, fn -> Language.normalize("some_word", :invalid_language) end)
    end

    test "removes apostrophe from words in english" do
      words = ["don't"]
      assert Language.normalize(words, :en) == ["dont"]
    end
  end

  describe "valid_graphemes/0" do
    test "returns a list of graphemes" do
      valid_graphemes = Language.valid_graphemes(:pt_br)
      assert is_list(valid_graphemes)
      assert [grapheme | _] = valid_graphemes
      assert is_binary(grapheme)
    end
  end
end
