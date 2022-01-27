defmodule Wordle.Feedback.Builder do
  alias Wordle.Feedback.Builder
  alias Linguistics.Grapheme

  defstruct [:acc, :counts, :right_word, :guessed_word, :size, position: 0]

  @type t :: %Builder{
          counts: Grapheme.counts(),
          right_word: String.t(),
          guessed_word: String.t(),
          acc: [Grapheme.t()],
          position: integer(),
          size: integer()
        }

  @spec new(String.t(), String.t()) :: t()
  def new(right_word, guessed_word) do
    counts = Grapheme.counts(right_word)
    acc = right_word |> String.graphemes() |> Enum.map(fn _grapheme -> "0" end)

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
      ^right_grapheme -> feedback |> decrease_count(grapheme) |> put_answer("2")
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
      _ -> feedback |> decrease_count(grapheme) |> put_answer("1")
    end
    |> next_position()
    |> partial_matches()
  end

  @spec as_string(t()) :: String.t()
  def as_string(feedback), do: feedback |> Map.get(:acc) |> Enum.join()

  @spec decrease_count(t(), Grapheme.t()) :: t()
  defp decrease_count(feedback, grapheme) do
    count = get_count(feedback, grapheme)

    feedback.counts
    |> Map.put(grapheme, count - 1)
    |> update_counts(feedback)
  end

  @spec increase_count(t(), Grapheme.t()) :: t()
  defp increase_count(%Builder{} = feedback, grapheme) do
    count = get_count(feedback, grapheme)

    feedback.counts
    |> Map.put(grapheme, count + 1)
    |> update_counts(feedback)
  end

  @spec get_count(t(), Grapheme.t()) :: integer()
  defp get_count(feedback, grapheme) do
    Map.get(feedback.counts, grapheme, 0)
  end

  @spec update_counts(Grapheme.counts(), t()) :: t()
  defp update_counts(new_counts, feedback) do
    Map.put(feedback, :counts, new_counts)
  end

  @spec put_answer(t(), Grapheme.t()) :: t()
  defp put_answer(feedback, one_or_two) when one_or_two in ~w(1 2) do
    position = feedback.position
    curr = Enum.at(feedback.acc, position)
    grapheme = String.at(feedback.right_word, position)

    {feedback, acc} =
      case curr do
        "0" -> {feedback, feedback.acc |> List.replace_at(position, one_or_two)}
        _ -> {increase_count(feedback, grapheme), feedback.acc}
      end

    %{feedback | acc: acc}
  end

  @spec next_position(t()) :: t()
  defp next_position(feedback), do: %{feedback | position: feedback.position + 1}
end
