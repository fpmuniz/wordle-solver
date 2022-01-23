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

  alias Wordle.Feedback
  alias Wordle.Game
  alias Wordle.Solver
  alias Score

  @type t :: %Solver{
          wordlist: Dictionary.t(),
          complements: Dictionary.t()
        }

  defstruct wordlist: [], complements: []

  @spec new(Dictionary.t()) :: t()
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
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(solver.wordlist, fn {letter_feedback, pos}, w ->
        letter = String.at(guess, pos)
        update_with_grapheme_feedback(w, letter, pos, letter_feedback)
      end)
      |> filter_wordlist_by_maxmin(Feedback.maxmin(guess, feedback))

    %{solver | wordlist: updated_wordlist}
  end

  @spec first_guesses(Dictionary.t(), Dictionary.t()) :: Dictionary.t()
  def first_guesses(wordlist, guesses \\ [])
  def first_guesses([], guesses), do: guesses

  def first_guesses([hd | _tl] = wordlist, guesses) do
    hd
    |> String.graphemes()
    |> Enum.reduce(wordlist, fn grapheme, wordlist -> reject_grapheme(wordlist, grapheme) end)
    |> first_guesses(guesses ++ [hd])
  end

  @spec solve(t(), Game.t()) :: {:error | :ok, Dictionary.t()}
  def solve(%Solver{wordlist: []}, %Game{guesses: guesses}), do: {:error, guesses}

  def solve(%Solver{wordlist: [best_guess | _]}, %Game{right_word: best_guess, guesses: guesses}),
    do: {:ok, [best_guess | guesses]}

  def solve(
        %Solver{complements: [best_guess | _]},
        %Game{right_word: best_guess, guesses: guesses}
      ),
      do: {:ok, [best_guess | guesses]}

  def solve(%Solver{complements: [guess | complements]} = solver, %Game{} = game) do
    game = Game.guess(game, guess)
    [feedback | _] = game.feedbacks

    %{solver | complements: complements}
    |> feedback(guess, feedback)
    |> order_by_scores()
    |> solve(game)
  end

  def solve(%Solver{wordlist: [guess | _], complements: []} = solver, %Game{} = game) do
    game = Game.guess(game, guess)
    [feedback | _] = game.feedbacks

    solver
    |> feedback(guess, feedback)
    |> order_by_scores()
    |> solve(game)
  end

  @spec solve_randomly(t(), Game.t()) :: {:ok | :error, Dictionary.t()}
  def solve_randomly(%{wordlist: []}, %{guesses: guesses}), do: {:error, guesses}

  def solve_randomly(%{wordlist: [right_word | _]}, %{guesses: guesses, right_word: right_word}),
    do: {:ok, [right_word | guesses]}

  def solve_randomly(solver, game) do
    wordlist = Enum.shuffle(solver.wordlist)
    [guess | _] = wordlist
    game = Game.guess(game, guess)
    [feedback | _] = game.feedbacks

    solver
    |> feedback(guess, feedback)
    |> solve_randomly(game)
  end

  @spec update_with_grapheme_feedback(Dictionary.t(), String.grapheme(), integer(), String.t()) ::
          [
            String.t()
          ]
  defp update_with_grapheme_feedback(wordlist, grapheme, position, feedback) do
    case feedback do
      "0" -> wordlist
      "1" -> wrong_position(wordlist, grapheme, position)
      "2" -> right_position(wordlist, grapheme, position)
    end
  end

  @spec reject_grapheme(Dictionary.t(), String.grapheme()) :: Dictionary.t()
  defp reject_grapheme(wordlist, grapheme) do
    Enum.reject(wordlist, &String.contains?(&1, grapheme))
  end

  @spec wrong_position(Dictionary.t(), String.grapheme(), integer()) :: Dictionary.t()
  defp wrong_position(wordlist, grapheme, position) do
    wordlist
    |> Enum.filter(&String.contains?(&1, grapheme))
    |> Enum.reject(&(String.at(&1, position) == grapheme))
  end

  @spec right_position(Dictionary.t(), String.grapheme(), integer()) :: Dictionary.t()
  defp right_position(wordlist, grapheme, position) do
    Enum.filter(wordlist, &(String.at(&1, position) == grapheme))
  end

  @spec order_by_scores(t()) :: t()
  defp order_by_scores(solver) do
    %{solver | wordlist: Score.order_by_scores(solver.wordlist)}
  end

  @spec filter_wordlist_by_maxmin(Dictionary.t(), Feedback.maxmin()) :: Dictionary.t()
  defp filter_wordlist_by_maxmin(wordlist, maxmin) do
    Enum.filter(wordlist, fn word ->
      counts = Score.grapheme_count(word)

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
end
