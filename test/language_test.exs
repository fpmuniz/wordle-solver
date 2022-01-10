defmodule LanguageTest do
  use ExUnit.Case
  doctest Language

  describe "normalize/2" do
    test "removes accents from portuguese-br words" do
      word = "áâàãçéêíóôõú"
      assert Language.normalize(word, :pt_br) == "aaaaceeiooou"
    end

    test "does not change unaccented lowcase letters" do
      word = ?a..?z |> Enum.to_list() |> List.to_string()
      assert Language.normalize(word, :pt_br) == word
    end

    test "raises when there are uppercase characters" do
      word = "OLA"
      assert_raise(FunctionClauseError, fn -> Language.normalize(word, :pt_br) end)
    end

    test "raises when there are special symbols characters" do
      word = "*(), "
      assert_raise(FunctionClauseError, fn -> Language.normalize(word, :pt_br) end)
    end
  end
end
