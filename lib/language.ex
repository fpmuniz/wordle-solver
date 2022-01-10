defmodule Language do
  def normalize(word, :pt_br), do: Language.PtBr.normalize(word)
end
