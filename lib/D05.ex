defmodule Aoc.D5 do
  @doc """
  iex> Aoc.D5.p1("inputs/05-test.txt")
  10
  """
  def p1(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> String.graphemes()
    |> react
    |> Enum.count()
  end

  @doc """
  iex> Aoc.D5.p2("inputs/05-test.txt")
  4
  """
  def p2(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> test_removal(
      [
        "a",
        "b",
        "c",
        "d",
        "e",
        "f",
        "g",
        "h",
        "i",
        "j",
        "k",
        "l",
        "m",
        "n",
        "o",
        "p",
        "q",
        "r",
        "s",
        "t",
        "u",
        "v",
        "w",
        "x",
        "y",
        "z"
      ],
      100_000
    )
  end

  def test_removal(_, [], curBest), do: curBest

  def test_removal(polymer, [toRemove | rest], curBest) do
    IO.inspect(toRemove)

    newLength =
      polymer
      |> String.replace(toRemove, "")
      |> String.replace(String.upcase(toRemove), "")
      |> String.graphemes()
      |> react()
      |> Enum.count()

    if newLength < curBest do
      test_removal(polymer, rest, newLength)
    else
      test_removal(polymer, rest, curBest)
    end
  end

  @doc """
  iex> Aoc.D5.react(["c", "b", "f", "F", "r", "l"])
  ["c", "b", "r", "l"]
  """
  def react([head | tail] = list) do
    result = Enum.reduce_while(tail, {head, 0, list}, &does_react?/2)

    case result do
      {_, _, newList} -> newList
      newList when is_list(newList) -> react(newList)
    end
  end

  @doc """
  iex> Aoc.D5.does_react?("a", {"A", 0, ["A", "a"]})
  {:halt, []}
  iex> Aoc.D5.does_react?("c", {"A", 0, ["A", "c"]})
  {:cont, {"c", 1, ["A", "c"]}}

  """
  def does_react?(current, {last, lastI, list}) do
    case is_same_letter_but_opposite_case?(last, current) do
      true -> {:halt, Enum.slice(list, 0, lastI) ++ Enum.slice(list, lastI + 2, Enum.count(list))}
      false -> {:cont, {current, lastI + 1, list}}
    end
  end

  def is_downcase?(letter), do: String.downcase(letter) == letter
  def is_upcase?(letter), do: String.upcase(letter) == letter

  @doc """
  iex> Aoc.D5.is_same_letter_but_opposite_case?("a", "A")
  true
  iex> Aoc.D5.is_same_letter_but_opposite_case?("a", "B")
  false
  iex> Aoc.D5.is_same_letter_but_opposite_case?("a", "a")
  false
  iex> Aoc.D5.is_same_letter_but_opposite_case?("a", "b")
  false
  iex> Aoc.D5.is_same_letter_but_opposite_case?("B", "b")
  true
  iex> Aoc.D5.is_same_letter_but_opposite_case?("B", "a")
  false
  iex> Aoc.D5.is_same_letter_but_opposite_case?("B", "B")
  false
  iex> Aoc.D5.is_same_letter_but_opposite_case?("B", "A")
  false
  """
  def is_same_letter_but_opposite_case?(first, second) do
    case String.downcase(first) == String.downcase(second) do
      true ->
        case is_downcase?(first) do
          true -> is_upcase?(second)
          false -> is_downcase?(second)
        end

      false ->
        false
    end
  end
end
