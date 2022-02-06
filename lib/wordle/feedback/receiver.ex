defmodule Wordle.Feedback.Receiver do
  alias Linguistics.Word
  alias Linguistics.Lexicon
  alias Wordle.Game
  alias Wordle.Feedback

  @type maxmin :: %{Word.grapheme() => [max: integer(), min: integer()]}

  @spec filter(Lexicon.t(), String.t(), Feedback.t()) :: Lexicon.t()
  def filter(lexicon, guess, response) do
    response
    |> Enum.with_index()
    |> Enum.reduce(lexicon, fn {grapheme_feedback, pos}, acc ->
      grapheme = String.at(guess, pos)
      filter_by_grapheme(acc, grapheme, pos, grapheme_feedback)
    end)
    |> filter_by_maxmin(maxmin(guess, response))
  end

  @spec maxmin(String.t(), Feedback.t()) :: maxmin()
  def maxmin(guessed_word, feedback) do
    n = String.length(guessed_word)
    guess_counts = Word.counts(guessed_word)
    feedback_counts = correct_grapheme_counts(guessed_word, feedback)

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

  @spec filter_by_grapheme(Lexicon.t(), Word.grapheme(), integer(), Game.classification()) ::
          Lexicon.t()
  defp filter_by_grapheme(lexicon, grapheme, position, feedback) do
    case feedback do
      :wrong -> lexicon
      :misplaced -> wrong_position(lexicon, grapheme, position)
      :correct -> right_position(lexicon, grapheme, position)
    end
  end

  @spec wrong_position(Lexicon.t(), Word.grapheme(), integer()) :: Lexicon.t()
  defp wrong_position(lexicon, grapheme, position) do
    lexicon
    |> Enum.filter(&String.contains?(&1, grapheme))
    |> Enum.reject(&(String.at(&1, position) == grapheme))
  end

  @spec right_position(Lexicon.t(), Word.grapheme(), integer()) :: Lexicon.t()
  defp right_position(lexicon, grapheme, position) do
    Enum.filter(lexicon, &(String.at(&1, position) == grapheme))
  end

  @spec filter_by_maxmin(Lexicon.t(), maxmin()) :: Lexicon.t()
  defp filter_by_maxmin(lexicon, maxmin) do
    Enum.filter(lexicon, fn word ->
      counts = Word.counts(word)

      maxmin
      |> Map.keys()
      |> Enum.reduce(true, fn grapheme, acc ->
        max = maxmin[grapheme][:max]
        min = maxmin[grapheme][:min]
        count = Map.get(counts, grapheme, 0)

        acc and count <= max and count >= min
      end)
    end)
  end

  @spec correct_grapheme_counts(String.t(), Feedback.t()) :: Word.counts()
  defp correct_grapheme_counts(guessed_word, response) do
    response
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {resp, position}, acc ->
      grapheme = String.at(guessed_word, position)
      acc = Map.put_new(acc, grapheme, 0)

      case resp do
        :wrong -> acc
        _ -> increase_count(acc, grapheme)
      end
    end)
  end

  @spec increase_count(Word.counts(), Word.grapheme()) :: Word.counts()
  defp increase_count(count_map, grapheme) when is_map(count_map) do
    count_map
    |> Map.get_and_update!(grapheme, fn count -> {count, count + 1} end)
    |> (&elem(&1, 1)).()
  end
end
