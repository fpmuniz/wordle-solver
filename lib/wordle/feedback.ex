defmodule Wordle.Feedback do
  alias Wordle.Feedback
  defstruct [:acc, :counts, :right_word, :guessed_word, :size, position: 0]

  @type maxmin :: %{Grapheme.t() => [max: integer(), min: integer()]}
  @type t :: %Feedback{
          counts: Grapheme.counts(),
          right_word: String.t(),
          guessed_word: String.t(),
          acc: [Grapheme.t()],
          position: integer(),
          size: integer()
        }

  @spec build(String.t(), String.t()) :: String.t()
  def build(right_word, guessed_word) do
    right_word
    |> new(guessed_word)
    |> exact_matches()
    |> partial_matches()
    |> as_string()
  end

  @spec maxmin(String.t(), String.t()) :: maxmin()
  def maxmin(guessed_word, response) do
    n = String.length(guessed_word)
    guess_counts = Grapheme.grapheme_count(guessed_word)
    feedback_counts = feedback_grapheme_counts(guessed_word, response)

    Map.merge(guess_counts, feedback_counts, fn _grapheme, guess_count, feedback_count ->
      min = feedback_count

      max =
        case guess_count > feedback_count do
          true -> feedback_count
          false -> n
        end

      [max: max, min: min]
    end)
  end

  @spec feedback_grapheme_counts(String.t(), String.t()) :: Grapheme.counts()
  defp feedback_grapheme_counts(guessed_word, response) do
    response
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {resp, position}, acc ->
      grapheme = String.at(guessed_word, position)
      acc = Map.put_new(acc, grapheme, 0)

      case resp do
        "0" -> acc
        _ -> increase_count(acc, grapheme)
      end
    end)
  end

  @spec new(String.t(), String.t()) :: Feedback.t()
  defp new(right_word, guessed_word) do
    counts = Grapheme.grapheme_count(right_word)
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
  defp exact_matches(%Feedback{position: x, size: x} = feedback), do: %{feedback | position: 0}

  defp exact_matches(feedback) do
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
  defp partial_matches(%Feedback{position: x, size: x} = feedback), do: %{feedback | position: 0}

  defp partial_matches(feedback) do
    grapheme = String.at(feedback.guessed_word, feedback.position)

    case get_count(feedback, grapheme) do
      0 -> feedback
      _ -> feedback |> decrease_count(grapheme) |> put_answer("1")
    end
    |> next_position()
    |> partial_matches()
  end

  @spec decrease_count(t(), Grapheme.t()) :: t()
  defp decrease_count(feedback, grapheme) do
    count = get_count(feedback, grapheme)

    feedback.counts
    |> Map.put(grapheme, count - 1)
    |> update_counts(feedback)
  end

  @spec increase_count(t(), Grapheme.t()) :: t()
  defp increase_count(%Feedback{} = feedback, grapheme) do
    count = get_count(feedback, grapheme)

    feedback.counts
    |> Map.put(grapheme, count + 1)
    |> update_counts(feedback)
  end

  @spec increase_count(Grapheme.counts(), Grapheme.t()) :: Grapheme.counts()
  defp increase_count(count_map, grapheme) when is_map(count_map) do
    count_map
    |> Map.get_and_update!(grapheme, fn count -> {count, count + 1} end)
    |> (&elem(&1, 1)).()
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

  @spec as_string(t()) :: String.t()
  defp as_string(feedback), do: feedback |> Map.get(:acc) |> Enum.join()
end
