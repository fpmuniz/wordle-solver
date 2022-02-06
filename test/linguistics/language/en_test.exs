defmodule Linguistics.Language.EnTest do
  alias Linguistics.Language.En
  use ExUnit.Case, async: true

  describe "normalize/2" do
    test "removes apostrophes" do
      word = "don't"
      assert En.normalize(word) == "dont"
    end
  end
end
