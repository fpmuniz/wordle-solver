defmodule Lexicon do
  @type t :: [String.t()]

  @path "lib/lexicon"

  @spec import(String.t()) :: t()
  def import(name) do
    "#{@path}/#{name}.txt"
    |> File.read!()
    |> String.split("\n")
  end

  @spec downcase(t()) :: t()
  def downcase(dict), do: dict |> Enum.map(&String.downcase/1)

  @spec trim(t()) :: t()
  def trim(dict), do: dict |> Enum.map(&String.trim/1)

  @spec filter_valid(t(), Regex.t()) :: t()
  def filter_valid(dict, pattern \\ ~r/^[a-z]+$/),
    do: dict |> Enum.filter(&String.match?(&1, pattern))

  @spec filter_by_number_of_graphenes(t(), integer()) :: t()
  def filter_by_number_of_graphenes(dict, n), do: dict |> Enum.filter(&(String.length(&1) == n))

  @spec export(t(), String.t()) :: :ok
  def export(dict, name) do
    dict
    |> Enum.join("\n")
    |> String.trim()
    |> (&File.write!("#{@path}/#{name}.txt", &1)).()
  end
end
