defmodule Wordle.Solver do
  @moduledoc ~S"""
  A basic module used to filter (previously sorted) words until it finds the correct one.

  Usage:

  iex> words = ~w(done gone stay play)
  iex> Solver.feedback(words, "stay", "0022")
  ["play"]
  iex> Solver.feedback(words, "0222")  # assumes the first word, which is "done"
  ["gone"]
  """

  @spec feedback([binary], binary) :: [binary]
  def feedback([best_guess | _] = wordlist, feedback) do
    feedback(wordlist, best_guess, feedback)
  end

  @spec feedback([binary], binary, binary) :: [binary]
  def feedback(wordlist, guess, feedback) do
    feedback
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.reduce(wordlist, fn {letter_feedback, pos}, w ->
      letter = String.at(guess, pos)
      update_with_letter_feedback(w, letter, pos, letter_feedback)
    end)
  end

  @spec first_guesses([binary], [binary]) :: [binary]
  def first_guesses(wordlist, guesses \\ [])
  def first_guesses([], guesses), do: guesses

  def first_guesses(wordlist = [hd | _tl], guesses) do
    hd
    |> String.codepoints()
    |> Enum.map_join(fn _ -> "0" end)
    |> (&feedback(wordlist, &1)).()
    |> first_guesses(guesses ++ [hd])
  end

  @spec update_with_letter_feedback([binary], binary, integer, binary) :: [binary]
  defp update_with_letter_feedback(wordlist, letter, position, feedback) do
    case feedback do
      "0" -> wrong_letter(wordlist, letter)
      "1" -> wrong_position(wordlist, letter, position)
      "2" -> right_position(wordlist, letter, position)
    end
  end

  @spec wrong_letter([binary], binary) :: [binary]
  defp wrong_letter(wordlist, letter) do
    Enum.reject(wordlist, &String.contains?(&1, letter))
  end

  @spec wrong_position([binary], binary, integer) :: [binary]
  defp wrong_position(wordlist, letter, position) do
    wordlist
    |> Enum.filter(&String.contains?(&1, letter))
    |> Enum.reject(&(String.at(&1, position) == letter))
  end

  @spec right_position([binary], binary, integer) :: [binary]
  defp right_position(wordlist, letter, position) do
    Enum.filter(wordlist, &(String.at(&1, position) == letter))
  end
end
