defmodule Wordle.Feedback do
  alias Wordle.Feedback.Builder
  alias Wordle.Feedback.Receiver
  alias Linguistics.Lexicon
  alias Wordle.Game

  @type t :: [Game.classification()]

  @spec build(String.t(), String.t()) :: t()
  def build(right_word, guessed_word) do
    right_word
    |> Builder.new(guessed_word)
    |> Builder.exact_matches()
    |> Builder.partial_matches()
    |> Builder.get_result()
  end

  @spec filter(Lexicon.t(), t()) :: Lexicon.t()
  def filter([], _response), do: []
  def filter([hd | _] = lexicon, response), do: Receiver.filter(lexicon, hd, response)

  @spec filter(Lexicon.t(), String.t(), t()) :: Lexicon.t()
  def filter(lexicon, guess, response), do: Receiver.filter(lexicon, guess, response)
end
