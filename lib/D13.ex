defmodule Aoc.D13 do
  def p1(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> build_map(%{}, [], 0)
    |> tick(0)
  end

  def build_map([], map, cars, _), do: {map, cars}

  def build_map([head | tail], map, cars, y) do
    {new_map, new_cars} = build_row(head, map, cars, y)
    build_map(tail, new_map, new_cars, y + 1)
  end

  def build_row(line, map, cars, y) do
    {new_map, new_cars, _, _} =
      Enum.reduce(String.graphemes(line), {map, cars, 0, y}, &parse_char/2)

    {new_map, new_cars}
  end

  def parse_char(" ", {map, cars, x, y}) do
    {map, cars, x + 1, y}
  end

  def parse_char(">", {map, cars, x, y}),
    do: {Map.put(map, {x, y}, "-"), [{x, y, :right, 0} | cars], x + 1, y}

  def parse_char("^", {map, cars, x, y}),
    do: {Map.put(map, {x, y}, "|"), [{x, y, :up, 0} | cars], x + 1, y}

  def parse_char("<", {map, cars, x, y}),
    do: {Map.put(map, {x, y}, "-"), [{x, y, :left, 0} | cars], x + 1, y}

  def parse_char("v", {map, cars, x, y}),
    do: {Map.put(map, {x, y}, "|"), [{x, y, :down, 0} | cars], x + 1, y}

  def parse_char(char, {map, cars, x, y}) do
    {Map.put(map, {x, y}, char), cars, x + 1, y}
  end

  def tick({map, cars}, tick) do
    {new_cars, one_left} = move_cars(map, sort_cars(cars), [])

    if one_left do
      new_cars
    else
      tick({map, new_cars}, tick + 1)
    end
  end

  def sort_cars(cars) do
    Enum.sort_by(cars, fn {x, y, _, _} -> {y, x} end)
  end

  def detect_collision(cars) do
    cars
    |> Enum.map(fn {x, y, _, _} -> {x, y} end)
    |> Enum.group_by(& &1)
    |> Enum.find(fn {_, val} ->
      Enum.count(val) == 2
    end)
  end

  @doc """
  iex> Aoc.D13.remove_collisions([{0, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 0, 0}])
  [{0, 1, 0, 0}]
  """
  def remove_collisions(cars) do
    collisions =
      cars
      |> Enum.map(fn {x, y, _, _} -> {x, y} end)
      |> Enum.group_by(& &1)
      |> Enum.find(fn {_, val} ->
        Enum.count(val) == 2
      end)

    if collisions == nil do
      cars
    else
      {_, [{col_x, col_y} | _]} = collisions

      Enum.reject(cars, fn {x, y, _, _} ->
        {x, y} == {col_x, col_y}
      end)
    end
  end

  def move_cars(_, [], updated_cars) do
    uncollided_cars = remove_collisions(updated_cars)

    if Enum.count(uncollided_cars) == 1 do
      {uncollided_cars, true}
    else
      {uncollided_cars, false}
    end
  end

  def move_cars(map, [{x, y, :left, num_turns} | rest_cars], updated_cars) do
    next_char = Map.get(map, {x - 1, y})

    new_updated_cars =
      case next_char do
        "\\" ->
          [{x - 1, y, :up, num_turns} | updated_cars]

        "+" ->
          case rem(num_turns, 3) do
            0 -> [{x - 1, y, :down, num_turns + 1} | updated_cars]
            1 -> [{x - 1, y, :left, num_turns + 1} | updated_cars]
            2 -> [{x - 1, y, :up, num_turns + 1} | updated_cars]
          end

        "/" ->
          [{x - 1, y, :down, num_turns} | updated_cars]

        "-" ->
          [{x - 1, y, :left, num_turns} | updated_cars]
      end

    uncollided_cars = remove_collisions(new_updated_cars ++ rest_cars)

    if Enum.count(uncollided_cars) == 1 do
      {uncollided_cars, true}
    else
      move_cars(
        map,
        rest_cars -- rest_cars -- uncollided_cars,
        new_updated_cars -- new_updated_cars -- uncollided_cars
      )
    end
  end

  def move_cars(map, [{x, y, :right, num_turns} | rest_cars], updated_cars) do
    next_char = Map.get(map, {x + 1, y})

    new_updated_cars =
      case next_char do
        "\\" ->
          [{x + 1, y, :down, num_turns} | updated_cars]

        "+" ->
          case rem(num_turns, 3) do
            0 -> [{x + 1, y, :up, num_turns + 1} | updated_cars]
            1 -> [{x + 1, y, :right, num_turns + 1} | updated_cars]
            2 -> [{x + 1, y, :down, num_turns + 1} | updated_cars]
          end

        "/" ->
          [{x + 1, y, :up, num_turns} | updated_cars]

        "-" ->
          [{x + 1, y, :right, num_turns} | updated_cars]
      end

    uncollided_cars = remove_collisions(new_updated_cars ++ rest_cars)

    if Enum.count(uncollided_cars) == 1 do
      {uncollided_cars, true}
    else
      move_cars(
        map,
        rest_cars -- rest_cars -- uncollided_cars,
        new_updated_cars -- new_updated_cars -- uncollided_cars
      )
    end
  end

  def move_cars(map, [{x, y, :up, num_turns} | rest_cars], updated_cars) do
    next_char = Map.get(map, {x, y - 1})

    new_updated_cars =
      case next_char do
        "\\" ->
          [{x, y - 1, :left, num_turns} | updated_cars]

        "+" ->
          case rem(num_turns, 3) do
            0 -> [{x, y - 1, :left, num_turns + 1} | updated_cars]
            1 -> [{x, y - 1, :up, num_turns + 1} | updated_cars]
            2 -> [{x, y - 1, :right, num_turns + 1} | updated_cars]
          end

        "/" ->
          [{x, y - 1, :right, num_turns} | updated_cars]

        "|" ->
          [{x, y - 1, :up, num_turns} | updated_cars]
      end

    uncollided_cars = remove_collisions(new_updated_cars ++ rest_cars)

    if Enum.count(uncollided_cars) == 1 do
      {uncollided_cars, true}
    else
      move_cars(
        map,
        rest_cars -- rest_cars -- uncollided_cars,
        new_updated_cars -- new_updated_cars -- uncollided_cars
      )
    end
  end

  def move_cars(map, [{x, y, :down, num_turns} | rest_cars], updated_cars) do
    next_char = Map.get(map, {x, y + 1})

    new_updated_cars =
      case next_char do
        "\\" ->
          [{x, y + 1, :right, num_turns} | updated_cars]

        "+" ->
          case rem(num_turns, 3) do
            0 -> [{x, y + 1, :right, num_turns + 1} | updated_cars]
            1 -> [{x, y + 1, :down, num_turns + 1} | updated_cars]
            2 -> [{x, y + 1, :left, num_turns + 1} | updated_cars]
          end

        "/" ->
          [{x, y + 1, :left, num_turns} | updated_cars]

        "|" ->
          [{x, y + 1, :down, num_turns} | updated_cars]
      end

    uncollided_cars = remove_collisions(new_updated_cars ++ rest_cars)

    if Enum.count(uncollided_cars) == 1 do
      {uncollided_cars, true}
    else
      move_cars(
        map,
        rest_cars -- rest_cars -- uncollided_cars,
        new_updated_cars -- new_updated_cars -- uncollided_cars
      )
    end
  end
end
