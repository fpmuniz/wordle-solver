defmodule Wordle.Feedback do
  alias Wordle.Feedback
  defstruct [:acc, :counts, :right_word, :guessed_word, :size, position: 0]

  @type counts_t :: %{String.grapheme() => integer()}
  @type t :: %Feedback{
          counts: counts_t(),
          right_word: String.t(),
          guessed_word: String.t(),
          acc: [String.grapheme()],
          position: integer(),
          size: integer()
        }

  @spec new(String.t(), String.t()) :: Feedback.t()
  def new(right_word, guessed_word) do
    counts = grapheme_counts(right_word)
    acc = right_word |> String.graphemes() |> Enum.map(fn _grapheme -> "0" end)

    %Feedback{
      right_word: right_word,
      counts: counts,
      guessed_word: guessed_word,
      acc: acc,
      size: String.length(right_word)
    }
  end

  @spec exact_matches(t()) :: t()
  def exact_matches(%Feedback{position: x, size: x} = feedback), do: %{feedback | position: 0}

  def exact_matches(feedback) do
    grapheme = String.at(feedback.guessed_word, feedback.position)
    right_grapheme = String.at(feedback.right_word, feedback.position)

    grapheme
    |> case do
      ^right_grapheme -> feedback |> grapheme_found(grapheme) |> put_answer("2")
      _ -> feedback
    end
    |> next_position()
    |> exact_matches()
  end

  @spec partial_matches(t()) :: t()
  def partial_matches(%Feedback{position: x, size: x} = feedback), do: %{feedback | position: 0}

  def partial_matches(feedback) do
    grapheme = String.at(feedback.guessed_word, feedback.position)

    case get_count(feedback, grapheme) do
      0 -> feedback
      _ -> feedback |> grapheme_found(grapheme) |> put_answer("1")
    end
    |> next_position()
    |> partial_matches()
  end

  @spec grapheme_found(t(), String.grapheme()) :: t()
  defp grapheme_found(feedback, grapheme) do
    count = get_count(feedback, grapheme)

    feedback.counts
    |> Map.put(grapheme, count - 1)
    |> update_counts(feedback)
  end

  @spec get_count(t(), String.grapheme()) :: integer()
  defp get_count(feedback, grapheme) do
    Map.get(feedback.counts, grapheme, 0)
  end

  @spec update_counts(counts_t(), t()) :: t()
  defp update_counts(new_counts, feedback) do
    Map.put(feedback, :counts, new_counts)
  end

  @spec grapheme_counts(String.t()) :: counts_t()
  defp grapheme_counts(word) do
    word
    |> String.graphemes()
    |> Enum.reduce(%{}, fn grapheme, counts ->
      count = Map.get(counts, grapheme, 0)

      Map.put(counts, grapheme, count + 1)
    end)
  end

  @spec put_answer(t(), String.grapheme()) :: t()
  defp put_answer(feedback, one_or_two) when one_or_two in ~w(1 2) do
    position = feedback.position
    acc = feedback.acc |> List.replace_at(position, one_or_two)

    %{feedback | acc: acc}
  end

  @spec next_position(t()) :: t()
  defp next_position(feedback), do: %{feedback | position: feedback.position + 1}
end
