defmodule Wordle.Game do
  alias Wordle.Game
  alias Wordle.Feedback

  @type t :: %Game{
          guesses: Lexicon.t(),
          feedbacks: Lexicon.t(),
          right_word: String.t(),
          wordlist: Lexicon.t(),
          graphemes: %{Grapheme.t() => classification()}
        }
  @type counts :: %{Grapheme.t() => integer()}
  @type classification :: :unknown | :invalid | :misplaced | :correct

  @default_valid_graphemes Language.valid_graphemes(:en)

  defstruct [
    :right_word,
    :wordlist,
    :graphemes,
    guesses: [],
    feedbacks: []
  ]

  @spec new(Lexicon.t(), String.t(), [Grapheme.t()]) :: t()
  def new(wordlist, right_word, valid_graphemes \\ @default_valid_graphemes) do
    case right_word in wordlist do
      true ->
        %{}
        |> Map.put(:wordlist, wordlist)
        |> Map.put(:right_word, right_word)
        |> Map.put(:graphemes, build_graphemes(valid_graphemes))
        |> (fn params -> struct!(Game, params) end).()

      false ->
        raise ArgumentError, "'#{right_word}' must be in wordlist."
    end
  end

  @spec guess(t(), String.t()) :: t()
  def guess(game, guess) do
    :ok = check_word_validity(game, guess)
    feedback = Feedback.build(game.right_word, guess)

    game
    |> put_guess(guess)
    |> put_feedback(feedback)
    |> organize_graphemes()
  end

  @spec put_guess(t(), String.t()) :: t()
  defp put_guess(game, guess) do
    %{game | guesses: [guess | game.guesses]}
  end

  @spec put_feedback(t(), String.t()) :: t()
  defp put_feedback(game, feedback) do
    %{game | feedbacks: [feedback | game.feedbacks]}
  end

  @spec organize_graphemes(t()) :: t()
  defp organize_graphemes(
         %Game{graphemes: graphemes, guesses: [guess | _], feedbacks: [feedback | _]} = game
       ) do
    guess = String.graphemes(guess)
    feedback = String.graphemes(feedback)

    [feedback, guess]
    |> Enum.zip()
    |> Enum.reduce(graphemes, fn {correctness, grapheme}, acc ->
      case correctness do
        "0" ->
          status = Map.get(acc, grapheme)
          new_status = if status == :unknown, do: :invalid, else: status
          Map.put(acc, grapheme, new_status)

        "1" ->
          status = Map.get(acc, grapheme)
          new_status = if status == :unknown, do: :misplaced, else: status
          Map.put(acc, grapheme, new_status)

        "2" ->
          status = Map.get(acc, grapheme)
          new_status = if status in [:unknown, :misplaced], do: :correct, else: status
          Map.put(acc, grapheme, new_status)
      end
    end)
    |> (fn graphemes -> %{game | graphemes: graphemes} end).()
  end

  @spec check_word_validity(t(), String.t()) :: :ok
  defp check_word_validity(game, guess) do
    cond do
      guess not in game.wordlist ->
        raise ArgumentError, "'#{guess}' is not in wordlist"

      String.length(game.right_word) != String.length(guess) ->
        raise ArgumentError,
              "guessed word '#{guess}' should have been #{String.length(game.right_word)} characters long."

      true ->
        :ok
    end
  end

  @spec build_graphemes([Grapheme.t()]) :: %{Grapheme.t() => classification()}
  defp build_graphemes(graphemes) do
    graphemes
    |> Enum.map(fn grapheme ->
      {grapheme, :unknown}
    end)
    |> Map.new()
  end
end
