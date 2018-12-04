defmodule Aoc.D3 do
  alias Aoc.Utils
  @doc """
  iex> Aoc.D3.p1("inputs/03-test.txt")
  4
  """
  def p1(filename) do
    filename
    |> buildFrequencyMap
    |> Enum.count(fn({_, num}) -> num < 0 end)
  end

  def p2(filename) do
    claims = filename
    |> File.read!()
    |> Utils.parseLinesFromFile()
    |> Enum.map(&parseClaimToTuple/1)
    Enum.reduce(claims, %{}, &processClaimTuple/2)
    |> findUniqueCut(claims)
  end

  def findUniqueCut(fMap, [{id, _, _, w, h} = claim | rest]) do
    IO.inspect(claim)
    case Enum.count(fMap, fn({_, val})-> val == id end) == w * h do
      true -> claim
      false -> findUniqueCut(fMap, rest)
    end
  end

  def buildFrequencyMap(filename) do
    filename
    |> File.read!()
    |> Utils.parseLinesFromFile()
    |> Enum.map(&parseClaimToTuple/1)
    |> Enum.reduce(%{}, &processClaimTuple/2)
  end

  def processClaimTuple(claim, acc) do
    processClaimColumn(acc, claim)
  end

  def processClaimColumn(acc, {_, _, _, _, 0}) do
    acc
  end

  @doc """
  iex> Aoc.D3.processClaimColumn(%{}, {1, 1, 1, 3, 3})
  %{
  {1, 1} => 1,
  {1, 2} => 1,
  {1, 3} => 1,
  {2, 1} => 1,
  {2, 2} => 1,
  {2, 3} => 1,
  {3, 1} => 1,
  {3, 2} => 1,
  {3, 3} => 1
  }
  """

  def processClaimColumn(acc, {id, xOffset, yOffset, width, height}) do
    coords = {(xOffset - 1) + width, (yOffset - 1) + height}
    acc = processClaimRow(acc, {id, xOffset, yOffset, width, height})
    case Map.has_key?(acc, coords) do
      true -> processClaimColumn(acc, {id, xOffset, yOffset, width, height - 1})
      false -> processClaimColumn(acc, {id, xOffset, yOffset, width, height - 1})
    end
  end

  def processClaimRow(acc, {_, _, _, 0, _}) do
    acc
  end

  def processClaimRow(acc, {id, xOffset, yOffset, width, height}) do
    coords = {(xOffset - 1) + width, (yOffset - 1) + height}
    case Map.has_key?(acc, coords) do
      true -> processClaimRow(%{acc | coords => -1}, {id, xOffset, yOffset, width - 1, height})
      false -> processClaimRow(Map.put(acc, coords, id), {id, xOffset, yOffset, width - 1, height})
    end
  end

  @doc """
  iex> Aoc.D3.parseClaimToTuple("#1 @ 1,3: 5x5")
  {1, 1, 3, 5, 5}

  iex> Aoc.D3.parseClaimToTuple("#100 @ 100,300: 50x500")
  {100, 100, 300, 50, 500}
  """

  def parseClaimToTuple(claim) do
    [_ , id, xOffset, yOffset, width, height] = Regex.run(~r/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/, claim)
    {String.to_integer(id), String.to_integer(xOffset), String.to_integer(yOffset), String.to_integer(width), String.to_integer(height)}
  end
end
