defmodule Aoc.D6 do
  alias Aoc.Utils

  def p1(filename) do
    landmarks =
      filename
      |> File.read!()
      |> Utils.parseLinesFromFile()
      |> insert_landmarks(%{}, 0)
      |> normalize_landmarks()

    map =
      landmarks
      |> build_map()

    remove_infinite_landmarks(landmarks, map)
    |> find_largest_real_area(
      map,
      0
    )
  end

  def p2(filename) do
    landmarks =
      filename
      |> File.read!()
      |> Utils.parseLinesFromFile()
      |> insert_landmarks(%{}, 0)
      |> normalize_landmarks()

    landmarks
    |> build_map_p2()
    |> Enum.count(& &1)
  end

  def build_map_p2(landmarks) do
    {width, height} = get_map_dimensions(landmarks)

    for x <- width,
        y <- height,
        do:
          Enum.reduce_while(landmarks, 0, fn {l_coords, _}, acc ->
            dist = manhattan_dist(l_coords, {x, y})

            cond do
              dist + acc < 10_000 -> {:cont, dist + acc}
              true -> {:halt, 100_000}
            end
          end) < 10_000
  end

  def remove_infinite_landmarks(landmarks, map) do
    all_ids = Enum.map(landmarks, fn {_, id} -> id end)
    {maxX, maxY} = {find_max_x(map), find_max_y(map)}
    ids_to_remove = for x <- 0..maxX, y <- [0, maxY], into: MapSet.new(), do: Map.get(map, {x, y})

    ids_to_remove =
      for x <- [0, maxX], y <- 0..maxY, into: ids_to_remove, do: Map.get(map, {x, y})

    all_ids -- MapSet.to_list(ids_to_remove)
  end

  def find_largest_real_area([], _, cur_largest),
    do: cur_largest

  def find_largest_real_area([head | tail], map, cur_largest) do
    count = Enum.count(map, fn {_, id} -> id == head end)

    if count > cur_largest do
      find_largest_real_area(tail, map, count)
    else
      find_largest_real_area(tail, map, cur_largest)
    end
  end

  @doc """
  iex> Aoc.D6.normalize_landmarks(%{{10, 10} => 0, {15, 9} => 1})
  %{{0, 1} => 0, {5, 0} => 1}
  """
  def normalize_landmarks(landmarks) do
    xOffset = find_min_x(landmarks)
    yOffset = find_min_y(landmarks)

    Enum.reduce(landmarks, %{}, fn {{x, y}, id}, acc ->
      Map.put(acc, {x - xOffset, y - yOffset}, id)
    end)
  end

  def build_map(landmarks) do
    {width, height} = get_map_dimensions(landmarks)

    for x <- width,
        y <- height,
        into: %{} do
      {_, id} =
        Enum.reduce(landmarks, {1000, -1}, fn {l_coords, l_id}, {cur_min, _} = acc ->
          dist = manhattan_dist(l_coords, {x, y})

          cond do
            dist < cur_min -> {dist, l_id}
            dist == cur_min -> {dist, -1}
            true -> acc
          end
        end)

      {{x, y}, id}
    end
  end

  @doc """
  iex> Aoc.D6.get_map_dimensions(%{{10, 10} => 0, {15, 9} => 1})
  {0..15, 0..10}
  """
  def get_map_dimensions(landmarks) do
    {0..find_max_x(landmarks), 0..find_max_y(landmarks)}
  end

  def insert_landmarks([], map, _), do: map

  def insert_landmarks([head | tail], map, id) do
    coords = parse_coords(head)
    insert_landmarks(tail, Map.put(map, coords, id), id + 1)
  end

  @doc """
  iex> Aoc.D6.manhattan_dist({0, 0}, {6, 6})
  12
  """
  def manhattan_dist({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def find_min_x(map), do: Enum.reduce(map, 1000, fn {{x, _}, _}, acc -> min(x, acc) end)
  def find_min_y(map), do: Enum.reduce(map, 1000, fn {{_, y}, _}, acc -> min(y, acc) end)
  def find_max_x(map), do: Enum.reduce(map, 0, fn {{x, _}, _}, acc -> max(x, acc) end)
  def find_max_y(map), do: Enum.reduce(map, 0, fn {{_, y}, _}, acc -> max(y, acc) end)

  @doc """
  iex> Aoc.D6.parse_coords("1, 2")
  {1, 2}
  """
  def parse_coords(line) do
    [x, y] = String.split(line, ", ")
    {String.to_integer(x), String.to_integer(y)}
  end
end
