defmodule Aoc do
  @moduledoc """
  Documentation for Aoc.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Aoc.dayOnePartOne()
      599

      iex> Aoc.dayOnePartTwo()
      81204

      iex> Aoc.dayTwoPartOne()
      5478

      iex> Aoc.dayTwoPartTwo()
      "qyzphxoiseldjrntfygvdmanu"

  """

  alias Aoc.D1
  alias Aoc.D2

  def dayOnePartOne do
    D1.p1()
  end

  def dayOnePartTwo do
    D1.p2()
  end

  def dayTwoPartOne do
    D2.p1("inputs/02-input.txt")
  end

  def dayTwoPartTwo do
    D2.p2("inputs/02-input.txt")
  end
end
