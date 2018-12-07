defmodule Aoc.D05A do
  def parseInput(filename) do
    filename
    |> File.read!()
    |> String.trim()
  end

  def p1(filename) do
    filename
    |> parseInput
    # |> react
    |> length
  end
end
