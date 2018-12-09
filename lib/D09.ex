defmodule Aoc.D9 do
  alias Aoc.Circle

  @doc """
  iex> Aoc.D9.p1("inputs/09-input.txt")
  413188
  """

  def p1(filename) do
    filename
    |> File.read!()
    |> String.split([" players; last marble is worth ", " points\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> start_game()
    |> Enum.map(fn {_, scores} -> Enum.sum(scores) end)
    |> Enum.max()
  end

  @doc """
  iex> Aoc.D9.p2("inputs/09-input.txt")
  3377272893
  """
  def p2(filename) do
    filename
    |> File.read!()
    |> String.split([" players; last marble is worth ", " points\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> start_game_p2()
    |> Enum.map(fn {_, scores} -> Enum.sum(scores) end)
    |> Enum.max()
  end

  def start_game_p2([num_players, num_marbles]) do
    circle = Circle.insert(Circle.new(), 0)
    players = for x <- 1..num_players, do: {x, []}
    marbles = for x <- 1..(num_marbles * 100), do: x
    play_turn_p2(circle, players, marbles)
  end

  def start_game([num_players, num_marbles]) do
    circle = [0]
    players = for x <- 1..num_players, do: {x, []}
    marbles = for x <- 1..num_marbles, do: x
    play_turn(circle, players, 0, marbles)
  end

  # Game Over
  def play_turn_p2(_, players, []), do: players

  # Score
  def play_turn_p2(circle, [{cur_player_id, cur_player_marbles} | rest_players], [
        cur_marble | rest_marbles
      ])
      when rem(cur_marble, 23) == 0 do
    # IO.inspect(cur_marble)
    new_circle = Circle.prev_by(circle, 7)
    extra_marble = Circle.value(new_circle)
    final_circle = Circle.remove(new_circle)

    play_turn_p2(
      final_circle,
      rest_players ++ [{cur_player_id, [cur_marble, extra_marble | cur_player_marbles]}],
      rest_marbles
    )
  end

  # Normal
  def play_turn_p2(circle, [cur_player | rest_players], [cur_marble | rest_marbles]) do
    # IO.inspect(cur_marble)
    new_circle = Circle.insert(Circle.next(Circle.next(circle)), cur_marble)
    play_turn_p2(new_circle, rest_players ++ [cur_player], rest_marbles)
  end

  # Game Over
  def play_turn(_, players, _, []), do: players

  # Score
  def play_turn(
        circle,
        [{cur_player_id, cur_player_marbles} | rest_players],
        current_marble_index,
        [
          cur_marble
          | rest_marbles
        ]
      )
      when rem(cur_marble, 23) == 0 do
    # IO.inspect(cur_marble)
    {new_circle, new_current_index, extra_marble} = claim_marbles(circle, current_marble_index)

    play_turn(
      new_circle,
      rest_players ++ [{cur_player_id, [cur_marble, extra_marble | cur_player_marbles]}],
      new_current_index,
      rest_marbles
    )
  end

  # Normal
  def play_turn(circle, [cur_player | rest_players], current_marble_index, [
        cur_marble
        | rest_marbles
      ]) do
    # IO.inspect(cur_marble)
    {new_circle, new_current_index} = insert_marble(circle, current_marble_index, cur_marble)

    play_turn(
      new_circle,
      rest_players ++ [cur_player],
      new_current_index,
      rest_marbles
    )
  end

  @doc """
  iex> Aoc.D9.claim_marbles([0,16, 8, 17, 4, 18, 9, 19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15], 13)
  {[0, 16, 8, 17, 4, 18, 19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15], 6, 9}
  """
  def claim_marbles(circle, cur_index) do
    claim_index = c_clockwise(circle, cur_index, 7)
    {List.delete_at(circle, claim_index), claim_index, Enum.at(circle, claim_index)}
  end

  @doc """
  iex> Aoc.D9.insert_marble([0], 0, 1)
  {[0, 1], 1}
  iex> Aoc.D9.insert_marble([0, 1], 1, 2)
  {[0, 2, 1], 1}
  """
  def insert_marble(circle, cur_index, marble) do
    new_index = next_index(circle, cur_index)
    {List.insert_at(circle, new_index, marble), new_index}
  end

  @doc """
  iex> Aoc.D9.next_index([0], 0)
  1
  iex> Aoc.D9.next_index([0, 1], 1)
  1
  iex> Aoc.D9.next_index([0, 2, 1], 1)
  3
  iex> Aoc.D9.next_index([0, 2, 1, 3], 3)
  1
  iex> Aoc.D9.next_index([0, 4, 2, 1, 3], 1)
  3
  """
  def next_index(list, current) when current + 2 > length(list), do: 1
  def next_index(_, current), do: current + 2

  @doc """
  iex> Aoc.D9.c_clockwise([0,16, 8, 17, 4, 18, 9, 19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15], 13, 7)
  6
  """

  def c_clockwise(list, current, to_traverse),
    do: rem(current - rem(to_traverse, length(list)) + length(list), length(list))
end
