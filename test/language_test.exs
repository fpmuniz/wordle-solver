defmodule LanguageTest do
  use ExUnit.Case, async: true
  doctest Language

  describe "normalize/2 with :pt_br language" do
    test "removes accents words" do
      words = ["áâàãçéêíóôõúÁÂÀÃÇÉÊÍÓÔÕÚ"]
      assert Language.normalize(words, :pt_br) == ["aaaaceeiooouAAAACEEIOOOU"]
    end

    test "does not change unaccented letters" do
      words =
        ?A..?z
        |> Enum.to_list()
        |> to_string()
        |> String.codepoints()

      assert Language.normalize(words, :pt_br) == words
    end
  end
end
