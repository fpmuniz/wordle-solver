defmodule Wordle.Solver do
  @moduledoc ~S"""
  A basic module used to filter (previously sorted) words until it finds the correct one.

  Usage:

  iex> words = ~w(done gone stay play)
  iex> solver = Solver.new(words)
  %Wordle.Solver{complements: ["done", "stay"], wordlist: ["done", "gone", "stay", "play"]}
  iex> Solver.feedback(solver, "stay", "0022")
  %Wordle.Solver{complements: ["done", "stay"], wordlist: ["play"]}
  iex> Solver.feedback(solver, "0222")  # assumes the first word, which is "done"
  %Wordle.Solver{complements: ["done", "stay"], wordlist: ["gone"]}
  """

  alias Wordle.Game
  alias Wordle.Solver
  alias Wordle.WordStats

  @type t :: %Solver{
          wordlist: [String.t()],
          complements: [String.t()]
        }

  defstruct wordlist: [], complements: []

  @spec new([String.t()]) :: t()
  def new(wordlist) do
    %Solver{wordlist: wordlist, complements: first_guesses(wordlist)}
  end

  @spec feedback(t(), String.t()) :: t()
  def feedback(%Solver{wordlist: [best_guess | _]} = solver, feedback) do
    feedback(solver, best_guess, feedback)
  end

  @spec feedback(t(), String.t(), String.t()) :: t()
  def feedback(solver, guess, feedback) do
    updated_wordlist =
      feedback
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.reduce(solver.wordlist, fn {letter_feedback, pos}, w ->
        letter = String.at(guess, pos)
        update_with_letter_feedback(w, letter, pos, letter_feedback)
      end)

    %{solver | wordlist: updated_wordlist}
  end

  @spec first_guesses([String.t()], [String.t()]) :: [String.t()]
  def first_guesses(wordlist, guesses \\ [])
  def first_guesses([], guesses), do: guesses

  def first_guesses([hd | _tl] = wordlist, guesses) do
    hd
    |> String.codepoints()
    |> Enum.reduce(wordlist, fn letter, wordlist -> wrong_letter(wordlist, letter) end)
    |> first_guesses(guesses ++ [hd])
  end

  @spec solve(t(), Game.t()) :: {:error | :ok, [String.t()]}
  def solve(%Solver{wordlist: []}, %Game{guesses: guesses}), do: {:error, guesses}

  def solve(%Solver{wordlist: [best_guess | _]}, %Game{right_word: best_guess, guesses: guesses}),
    do: {:ok, [best_guess | guesses]}

  def solve(
        %Solver{complements: [best_guess | _]},
        %Game{right_word: best_guess, guesses: guesses}
      ),
      do: {:ok, [best_guess | guesses]}

  def solve(%Solver{complements: [guess | complements]} = solver, %Game{} = game) do
    {game, feedback} = Game.guess(game, guess)

    %{solver | complements: complements}
    |> feedback(guess, feedback)
    |> order_by_scores()
    |> solve(game)
  end

  def solve(%Solver{wordlist: [guess | _], complements: []} = solver, %Game{} = game) do
    {game, feedback} = Game.guess(game, guess)

    solver
    |> feedback(guess, feedback)
    |> order_by_scores()
    |> solve(game)
  end

  @spec solve_randomly(t(), Game.t()) :: {:ok | :error, [String.t()]}
  def solve_randomly(%{wordlist: []}, %{guesses: guesses}), do: {:error, guesses}

  def solve_randomly(%{wordlist: [right_word | _]}, %{guesses: guesses, right_word: right_word}),
    do: {:ok, [right_word | guesses]}

  def solve_randomly(solver, game) do
    wordlist = Enum.shuffle(solver.wordlist)
    [guess | _] = wordlist
    {game, feedback} = Game.guess(game, guess)

    solver
    |> feedback(guess, feedback)
    |> solve_randomly(game)
  end

  @spec update_with_letter_feedback([String.t()], String.t(), integer(), String.t()) :: [
          String.t()
        ]
  defp update_with_letter_feedback(wordlist, letter, position, feedback) do
    case feedback do
      "0" -> wrong_letter(wordlist, letter)
      "1" -> wrong_position(wordlist, letter, position)
      "2" -> right_position(wordlist, letter, position)
    end
  end

  @spec wrong_letter([String.t()], String.t()) :: [String.t()]
  defp wrong_letter(wordlist, letter) do
    Enum.reject(wordlist, &String.contains?(&1, letter))
  end

  @spec wrong_position([String.t()], String.t(), integer()) :: [String.t()]
  defp wrong_position(wordlist, letter, position) do
    wordlist
    |> Enum.filter(&String.contains?(&1, letter))
    |> Enum.reject(&(String.at(&1, position) == letter))
  end

  @spec right_position([String.t()], String.t(), integer()) :: [String.t()]
  defp right_position(wordlist, letter, position) do
    Enum.filter(wordlist, &(String.at(&1, position) == letter))
  end

  defp order_by_scores(solver) do
    %{solver | wordlist: WordStats.order_by_scores(solver.wordlist)}
  end
end
