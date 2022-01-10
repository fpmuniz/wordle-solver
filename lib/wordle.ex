defmodule Wordle do
  @type t :: %__MODULE__{}

  defstruct [:words, :scores, :dict_file, :language, :word_size]

  def new(word_dict_filename, language, word_size) do
    %__MODULE__{dict_file: word_dict_filename, language: language, word_size: word_size}
    |> import_words()
    |> calculate_scores()
    |> sort_wordlist()
  end

  @spec suggest(t()) :: String.t()
  def suggest(%__MODULE__{words: [hd | _tl]}), do: hd

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
      |> Language.normalize(language)

    %__MODULE__{wordle | words: words}
  end

  defp calculate_scores(wordle = %__MODULE__{words: words, word_size: word_size}) do
    scores =
      words
      |> WordStats.filter_words_by_size(word_size)
      |> WordStats.letter_frequencies()

    %__MODULE__{wordle | scores: scores}
  end

  defp sort_wordlist(wordle = %__MODULE__{words: words, scores: scores}) do
    %__MODULE__{wordle | words: WordStats.order_by_scores(words, scores)}
  end
end
