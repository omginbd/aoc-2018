defmodule Aoc.D2 do
  
  @doc """
    iex> Aoc.D2.p1("inputs/02-test.txt")
    12
  """
  def p1(filename) do
    {twos, threes} = File.read!(filename) |>
    parseFile() |>
    Enum.reduce({0, 0}, fn(id, acc) -> processId(id, acc) end)
    twos * threes
  end

  @doc """
  iex> Aoc.D2.p2("inputs/02-test2.txt")
  "fgij"
  """

  def p2(filename) do
    File.read!(filename) |>
    parseFile() |>
    Enum.map(&(String.graphemes &1)) |>
    compareAllIds()
  end

  def compareAllIds ([head | tail]) do
    case compareAllIdsToHead([head | tail]) do
      {first, second} -> eliminateDifference(first, second)
      false -> compareAllIds(tail ++ [head])
    end
  end

  @doc """
  iex> Aoc.D2.eliminateDifference(["a", "b", "c"], ["a", "e", "c"])
  "ac"
  """

  def eliminateDifference(first, second) do
    Enum.zip(first, second) |>
    Enum.filter(fn({left, right}) -> left == right end) |>
    Enum.map(fn({left, _}) -> left end) |>
    Enum.reduce("", &(&2 <> &1))
  end

  def compareAllIdsToHead([_ | []]) do
    false
  end

  def compareAllIdsToHead([head | rest]) do
    [second | rest] = rest
    case idsHaveExactlyOneDifference(head, second) do
      true -> {head, second}
      false -> compareAllIdsToHead([head | rest])
    end
  end

  @doc """
  iex> Aoc.D2.idsHaveExactlyOneDifference(["a", "b", "c"], ["d", "e", "f"])
  false

  iex> Aoc.D2.idsHaveExactlyOneDifference(["a", "b", "c"], ["a", "e", "c"])
  true
  """

  def idsHaveExactlyOneDifference(first, second) do
    Enum.zip(first, second) |>
    Enum.count(fn({left, right}) -> left != right end) == 1
  end

  def parseFile(file) do
    String.trim(file) |>
    String.split("\n")
  end

  @doc """
  iex> Aoc.D2.processId("abc", {0, 0})
  {0, 0}

  iex> Aoc.D2.processId("aabbb", {0, 0})
  {1, 1}

  iex> Aoc.D2.processId("aaaa", {0, 0})
  {0, 0}
  """

  def processId(id, {twos, threes}) do
    counts = String.graphemes(id) |>
    getCounts(%{})
    newTwos = if hasExactlyN?(counts, 2), do: twos + 1, else: twos
    newThrees = if hasExactlyN?(counts, 3), do: threes + 1, else: threes
    {newTwos, newThrees}
  end

  @doc """
  iex> Aoc.D2.getCounts(["a", "b", "a"], %{})
  %{"a" => 2, "b" => 1}
  """

  def getCounts([], curCounts), do: curCounts

  def getCounts([head | tail], curCounts) do
    case Map.has_key?(curCounts, head) do
      false -> getCounts(tail, Map.put(curCounts, head, 1))
      true -> getCounts(tail, %{curCounts | head => curCounts[head] + 1})
    end
  end

  @doc """
  iex> Aoc.D2.hasExactlyN?(%{"a" => 2}, 2)
  true

  iex> Aoc.D2.hasExactlyN?(%{"a" => 3}, 2)
  false

  """
  def hasExactlyN?(counts, n), do: Enum.any?(counts, fn({_, x}) -> x == n end)
end
