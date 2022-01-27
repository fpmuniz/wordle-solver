defmodule Wordle.Feedback do
  alias Wordle.Feedback.Builder
  alias Wordle.Feedback.Receiver

  @spec build(String.t(), String.t()) :: String.t()
  def build(right_word, guessed_word) do
    right_word
    |> Builder.new(guessed_word)
    |> Builder.exact_matches()
    |> Builder.partial_matches()
    |> Builder.as_string()
  end

  @spec filter(Lexicon.t(), String.t()) :: Lexicon.t()
  def filter([], _response), do: []
  def filter([hd | _] = lexicon, response), do: Receiver.filter(lexicon, hd, response)

  @spec filter(Lexicon.t(), String.t(), String.t()) :: Lexicon.t()
  def filter(lexicon, guess, response), do: Receiver.filter(lexicon, guess, response)
end
