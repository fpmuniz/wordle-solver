defmodule Linguistics.Language.PtBrTest do
  alias Linguistics.Language.PtBr
  use ExUnit.Case, async: true

  describe "normalize/2" do
    test "removes accents words" do
      word = "áâàãçéêíóôõúÁÂÀÃÇÉÊÍÓÔÕÚ"
      assert PtBr.normalize(word) == "aaaaceeiooouAAAACEEIOOOU"
    end
  end
end
