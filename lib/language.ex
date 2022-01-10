defmodule Language do
  def normalize(word, :pt_br), do: Language.PtBr.normalize(word)
  def normalize(word, _), do: word
end
