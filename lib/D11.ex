defmodule Aoc.D11 do
  def p1(serial_number) do
    map =
      for y <- 1..300,
          x <- 1..300,
          into: %{},
          do: {{x, y}, calculate_cell_value({x, y}, serial_number)}

    find_best_square(map)
  end

  def p2(serial_number) do
    map =
      for y <- 1..300,
          x <- 1..300,
          into: %{},
          do: {{x, y}, calculate_cell_value({x, y}, serial_number)}

    find_best_square_p2(map)
  end

  def find_best_square(fuel_cell_map) do
    Enum.reduce(fuel_cell_map, {-1, -1, -1000}, &calculate_square_value(&1, &2, fuel_cell_map))
  end

  def find_best_square_p2(map) do
    Enum.reduce(2..300, -100_000, fn n, best_so_far ->
      IO.inspect(n)

      {x, y, best} =
        Enum.reduce(
          map,
          {-1, -1, -100_000},
          &calculate_square_value_p2(&1, &2, map, n)
        )

      if best > best_so_far do
        IO.inspect({x, y, best, n})
        best
      else
        best_so_far
      end
    end)
  end

  def calculate_square_value_p2({{x, y}, _}, acc, _, n)
      when x > 300 - (n - 1) or y > 300 - (n - 1),
      do: acc

  def calculate_square_value_p2({{x, y}, _}, {_, _, best_value} = acc, fuel_cell_map, n) do
    new = get_nxn_box(fuel_cell_map, {x, y}, n)

    if new > best_value do
      {x, y, new}
    else
      acc
    end
  end

  def calculate_square_value({{x, y}, _}, acc, _) when x > 298 or y > 298, do: acc

  def calculate_square_value({{x, y}, _}, {_, _, best_value} = acc, fuel_cell_map) do
    new = get_3x3_box(fuel_cell_map, {x, y})

    if new > best_value do
      {x, y, new}
    else
      acc
    end
  end

  def get_nxn_box(fuel_cell_map, {top_left_x, top_left_y}, n) do
    box =
      for y <- 0..(n - 1),
          x <- 0..(n - 1),
          do: Map.get(fuel_cell_map, {top_left_x + x, top_left_y + y})

    Enum.sum(box)
  end

  def get_3x3_box(fuel_cell_map, {top_left_x, top_left_y}) do
    box =
      for y <- 0..2,
          x <- 0..2,
          do: Map.get(fuel_cell_map, {top_left_x + x, top_left_y + y})

    Enum.sum(box)
  end

  @doc """
  iex> Aoc.D11.calculate_cell_value({3, 5}, 8)
  4
  iex> Aoc.D11.calculate_cell_value({122, 79}, 57)
  -5
  iex> Aoc.D11.calculate_cell_value({217, 196}, 39)
  0
  iex> Aoc.D11.calculate_cell_value({101, 153}, 71)
  4
  """
  def calculate_cell_value({x, y}, serial_number) do
    rack_id = x + 10
    value = (rack_id * y + serial_number) * rack_id
    value = get_hundreds_digit(value)
    value - 5
  end

  def get_hundreds_digit(num), do: div(rem(num, 1000), 100)
end
