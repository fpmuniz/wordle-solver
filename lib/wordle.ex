defmodule Wordle do
  @moduledoc ~S"""
  Basic state of an wordle game. The struct in this file retains information about the game,
  including the sorted word list, according to how likely it is to be the right word; all words that
  have been suggested so far; the scores each letter has; and the name of the file that was used as
  a dictionary.
  """

  @type t :: %Wordle{
          words: list(binary),
          scores: map,
          suggestions: [binary]
        }

  defstruct [:words, suggestions: [], scores: %{}]

  defmodule UnsolvableError do
    defexception [:message]
  end

  @spec new([binary]) :: t
  def new(word_list) when is_list(word_list),
    do: %Wordle{words: word_list} |> calculate_scores() |> suggest()

  @spec import_words(binary, atom) :: [binary]
  def import_words(dict_file, language) do
    dict_file
    |> Parser.import_dictionary()
    |> Parser.parse_words()
    |> Enum.map(&Language.normalize(&1, language))
  end

  @spec feedback(Wordle.t(), binary) :: Wordle.t()
  def feedback(wordle = %Wordle{suggestions: [best_guess | _]}, feedback) do
    feedback
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.reduce(wordle, fn {letter_feedback, pos}, acc ->
      letter = String.at(best_guess, pos)

      case letter_feedback do
        "0" -> wrong_letter(acc, letter)
        "1" -> wrong_position(acc, letter, pos)
        "2" -> right_position(acc, letter, pos)
      end
    end)
    |> suggest()
  end

  @spec wrong_letter(Wordle.t(), binary) :: Wordle.t()
  def wrong_letter(wordle, letter) do
    words = Enum.reject(wordle.words, &String.contains?(&1, letter))

    %Wordle{wordle | words: words}
  end

  @spec wrong_position(Wordle.t(), binary, integer) :: Wordle.t()
  def wrong_position(wordle, letter, position) do
    words =
      wordle.words
      |> Enum.filter(&String.contains?(&1, letter))
      |> Enum.reject(&(String.at(&1, position) == letter))

    %Wordle{wordle | words: words}
  end

  @spec right_position(Wordle.t(), binary, integer) :: Wordle.t()
  def right_position(wordle, letter, position) do
    words = Enum.filter(wordle.words, &(String.at(&1, position) == letter))

    %Wordle{wordle | words: words}
  end

  @spec solve(Wordle.t(), binary) :: {:ok | :error, Wordle.t()}
  def solve(wordle = %Wordle{suggestions: [suggestion | _tl]}, suggestion), do: {:ok, wordle}
  def solve(wordle = %Wordle{words: []}, _right_word), do: {:error, wordle}

  def solve(wordle, right_word) do
    feedback = build_feedback(wordle, right_word)

    wordle
    |> feedback(feedback)
    |> solve(right_word)
  end

  @spec calculate_scores(Wordle.t()) :: Wordle.t()
  defp calculate_scores(wordle) do
    scores = WordStats.letter_frequencies(wordle.words)
    words = WordStats.order_by_scores(wordle.words, scores)

    %Wordle{wordle | scores: scores, words: words}
  end

  @spec suggest(Wordle.t()) :: Wordle.t()
  def suggest(wordle = %Wordle{words: []}), do: wordle

  def suggest(wordle) do
    [best_guess | _tl] = wordle.words

    %Wordle{wordle | suggestions: [best_guess | wordle.suggestions]}
  end

  @spec build_feedback(Wordle.t(), binary) :: binary
  defp build_feedback(wordle, right_word) do
    [suggestion | _] = wordle.words

    suggestion
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.map_join(fn {letter, pos} ->
      cond do
        letter == String.at(right_word, pos) -> "2"
        String.contains?(right_word, letter) -> "1"
        true -> "0"
      end
    end)
  end
end
