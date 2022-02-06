defmodule Linguistics.Language.EnTest do
  alias Linguistics.Language.En
  use ExUnit.Case, async: true

  describe "normalize/2" do
    test "removes apostrophes" do
      word = "don't"
      assert En.normalize(word) == "dont"
    end
  end

  describe "valid_graphemes/0" do
    test "returns a list of graphemes" do
      valid_graphemes = En.valid_graphemes()
      assert is_list(valid_graphemes)
      assert [grapheme | _] = valid_graphemes
      assert is_binary(grapheme)
    end
  end
end
