defmodule Aoc.Utils do
  def parseLinesFromFile(file) do
    file
    |> String.split("\n", trim: true)
  end
end
