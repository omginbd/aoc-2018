defmodule Aoc.D10 do
  def p1(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_coords/1)
    |> build_star_map
    |> play_message
  end

  def parse_coords(line) do
    [x, y, dx, dy] =
      String.split(line, ["position=<", "> velocity=<", ">", ","], trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.to_integer/1)

    {x, y, dx, dy}
  end

  def build_star_map(coords) do
    Enum.reduce(coords, %{}, fn {x, y, dx, dy}, acc ->
      Map.put(acc, {x, y}, {dx, dy})
    end)
  end

  def play_message(star_map, num_seconds \\ 0) do
    IO.inspect(num_seconds, label: "num seconds")
    IO.puts(print_star_map(star_map))
    play_message(update_star_map(star_map), num_seconds + 1)
  end

  @doc """
  iex> Aoc.D10.print_star_map(%{{0, 0} => {-1, 2}, {5, 4} => {0, 2}})
  "# . . . . . \n. . . . . . \n. . . . . . \n. . . . . . \n. . . . . # \n"
  """
  def print_star_map(map) do
    {min_x, min_y, max_x, max_y} = min_max = get_map_dimensions(map)
    IO.inspect(min_max)

    if abs(max_x - min_x) < 100 do
      as_list =
        for y <- min_y..max_y, x <- min_x..max_x do
          char =
            cond do
              Map.has_key?(map, {x, y}) -> "#"
              true -> "."
            end

          if x == max_x do
            char <> <<10>>
          else
            char
          end
        end

      Process.sleep(200)
      Enum.join(as_list)
    else
      "Too big" <> to_string(abs(max_x - min_x))
    end
  end

  def get_map_dimensions(map) do
    Enum.reduce(map, {1000, 1000, -1000, -1000}, fn {{x, y}, _}, {min_x, min_y, max_x, max_y} ->
      {min(x, min_x), min(y, min_y), max(x, max_x), max(y, max_y)}
    end)
  end

  @doc """
  iex> Aoc.D10.update_star_map(%{{0, 0} => {-1, 2}, {5, 4} => {0, 2}})
  %{{-1, 2} => {-1, 2}, {5, 6} => {0, 2}}
  """
  def update_star_map(map), do: Enum.reduce(map, %{}, &handle_map_update/2)

  def handle_map_update({_, []}, acc), do: acc

  def handle_map_update({{x, y} = coords, [{dx, dy} | tail]}, acc) do
    new_x = x + dx
    new_y = y + dy

    if Map.has_key?(acc, {new_x, new_y}) do
      if is_list(Map.get(acc, {new_x, new_y})) do
        handle_map_update(
          {coords, tail},
          Map.put(acc, {new_x, new_y}, [{dx, dy} | Map.get(acc, {new_x, new_y})])
        )
      else
        handle_map_update(
          {coords, tail},
          Map.put(acc, {new_x, new_y}, [{dx, dy}, Map.get(acc, {new_x, new_y})])
        )
      end
    else
      handle_map_update(
        {coords, tail},
        Map.put(acc, {new_x, new_y}, {dx, dy})
      )
    end
  end

  def handle_map_update({{x, y}, {dx, dy}}, acc) do
    new_x = x + dx
    new_y = y + dy

    if Map.has_key?(acc, {new_x, new_y}) do
      if is_list(Map.get(acc, {new_x, new_y})) do
        Map.put(acc, {new_x, new_y}, [{dx, dy} | Map.get(acc, {new_x, new_y})])
      else
        Map.put(acc, {new_x, new_y}, [{dx, dy}, Map.get(acc, {new_x, new_y})])
      end
    else
      Map.put(acc, {new_x, new_y}, {dx, dy})
    end
  end
end
