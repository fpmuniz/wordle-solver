defmodule Wordle do
  @type t :: %__MODULE__{}

  defstruct [:words, :scores, :dict_file, :language, :word_size, :suggestion, attempts: 0]

  def new(word_dict_filename, language, word_size) do
    %__MODULE__{dict_file: word_dict_filename, language: language, word_size: word_size}
    |> import_words()
    |> calculate_scores()
    |> sort_wordlist()
    |> suggest()
  end

  @spec feedback(t(), String.t()) :: t()
  def feedback(wordle = %__MODULE__{suggestion: suggestion}, feedback) do
    feedback
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.reduce(wordle, fn {guess, pos}, acc ->
      letter = String.at(suggestion, pos)
      case guess do
        "0" -> wrong_letter(acc, letter)
        "1" -> wrong_position(acc, letter, pos)
        "2" -> right_position(acc, letter, pos)
      end
    end)
    |> suggest()
  end

  @spec wrong_letter(t(), String.t()) :: t()
  def wrong_letter(wordle = %__MODULE__{words: words}, letter) do
    words = Enum.reject(words, &String.contains?(&1, letter))

    %__MODULE__{wordle | words: words}
  end

  @spec wrong_position(t(), String.t(), integer()) :: t()
  def wrong_position(wordle = %__MODULE__{words: words}, letter, position) do
    words =
      words
      |> Enum.filter(&String.contains?(&1, letter))
      |> Enum.reject(&(String.at(&1, position) == letter))

    %__MODULE__{wordle | words: words}
  end

  @spec right_position(t(), String.t(), integer()) :: t()
  def right_position(wordle = %__MODULE__{words: words}, letter, position) do
    words = Enum.filter(words, &(String.at(&1, position) == letter))

    %__MODULE__{wordle | words: words}
  end

  defp import_words(wordle = %__MODULE__{dict_file: filename, language: language}) do
    words =
      filename
      |> Parser.import_dictionary()
      |> Parser.parse_words()
      |> Enum.map(&Language.normalize(&1, language))

    %__MODULE__{wordle | words: words}
  end

  defp calculate_scores(wordle = %__MODULE__{words: words, word_size: word_size}) do
    words = WordStats.filter_words_by_size(words, word_size)
    scores = WordStats.letter_frequencies(words)

    %__MODULE__{wordle | scores: scores, words: words}
  end

  defp sort_wordlist(wordle = %__MODULE__{words: words, scores: scores}) do
    %__MODULE__{wordle | words: WordStats.order_by_scores(words, scores)}
  end

  defp suggest(wordle = %__MODULE__{words: [hd | _tl], attempts: attempts}) do
    %__MODULE__{wordle | suggestion: hd, attempts: attempts + 1}
  end

  defp suggest(wordle = %__MODULE__{words: []}), do: %__MODULE__{wordle | suggestion: nil}
end
