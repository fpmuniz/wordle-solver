defmodule Wordle.Feedback.Builder do
  alias Wordle.Feedback.Builder
  alias Wordle.Feedback
  alias Linguistics.Word
  alias Wordle.Game

  defstruct [:acc, :counts, :right_word, :guessed_word, :size, position: 0]

  @type t :: %Builder{
          counts: Word.counts(),
          right_word: String.t(),
          guessed_word: String.t(),
          acc: Feedback.t(),
          position: integer(),
          size: integer()
        }

  @spec new(String.t(), String.t()) :: t()
  def new(right_word, guessed_word) do
    counts = Word.counts(right_word)
    acc = right_word |> String.graphemes() |> Enum.map(fn _grapheme -> :wrong end)

    %Builder{
      right_word: right_word,
      counts: counts,
      guessed_word: guessed_word,
      acc: acc,
      size: String.length(right_word)
    }
  end

  @spec exact_matches(t()) :: t()
  def exact_matches(%Builder{position: x, size: x} = feedback), do: %{feedback | position: 0}

  def exact_matches(feedback) do
    grapheme = String.at(feedback.guessed_word, feedback.position)
    right_grapheme = String.at(feedback.right_word, feedback.position)

    grapheme
    |> case do
      ^right_grapheme -> feedback |> decrease_count(grapheme) |> put_answer(:correct)
      _ -> feedback
    end
    |> next_position()
    |> exact_matches()
  end

  @spec partial_matches(t()) :: t()
  def partial_matches(%Builder{position: x, size: x} = feedback), do: %{feedback | position: 0}

  def partial_matches(feedback) do
    grapheme = String.at(feedback.guessed_word, feedback.position)

    case get_count(feedback, grapheme) do
      0 -> feedback
      _ -> feedback |> decrease_count(grapheme) |> put_answer(:misplaced)
    end
    |> next_position()
    |> partial_matches()
  end

  @spec get_feedback(t()) :: Feedback.t()
  def get_feedback(feedback), do: feedback |> Map.get(:acc)

  @spec decrease_count(t(), Word.grapheme()) :: t()
  defp decrease_count(feedback, grapheme) do
    count = get_count(feedback, grapheme)

    feedback.counts
    |> Map.put(grapheme, count - 1)
    |> update_counts(feedback)
  end

  @spec increase_count(t(), Word.grapheme()) :: t()
  defp increase_count(%Builder{} = feedback, grapheme) do
    count = get_count(feedback, grapheme)

    feedback.counts
    |> Map.put(grapheme, count + 1)
    |> update_counts(feedback)
  end

  @spec get_count(t(), Word.grapheme()) :: integer()
  defp get_count(feedback, grapheme) do
    Map.get(feedback.counts, grapheme, 0)
  end

  @spec update_counts(Word.counts(), t()) :: t()
  defp update_counts(new_counts, feedback) do
    Map.put(feedback, :counts, new_counts)
  end

  @spec put_answer(t(), Game.classification()) :: t()
  defp put_answer(feedback, classification) when classification in [:misplaced, :correct] do
    position = feedback.position
    curr = Enum.at(feedback.acc, position)
    grapheme = String.at(feedback.right_word, position)

    {feedback, acc} =
      case curr do
        :wrong -> {feedback, feedback.acc |> List.replace_at(position, classification)}
        _ -> {increase_count(feedback, grapheme), feedback.acc}
      end

    %{feedback | acc: acc}
  end

  @spec next_position(t()) :: t()
  defp next_position(feedback), do: %{feedback | position: feedback.position + 1}
end
