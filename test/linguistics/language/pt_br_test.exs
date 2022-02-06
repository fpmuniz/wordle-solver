defmodule Linguistics.Language.PtBrTest do
  alias Linguistics.Language.PtBr
  use ExUnit.Case, async: true

  describe "normalize/2" do
    test "removes accents words" do
      word = "áâàãçéêíóôõúÁÂÀÃÇÉÊÍÓÔÕÚ"
      assert PtBr.normalize(word) == "aaaaceeiooouAAAACEEIOOOU"
    end
  end

  describe "valid_graphemes/0" do
    test "returns a list of graphemes" do
      valid_graphemes = PtBr.valid_graphemes()
      assert is_list(valid_graphemes)
      assert [grapheme | _] = valid_graphemes
      assert is_binary(grapheme)
    end
  end
end
