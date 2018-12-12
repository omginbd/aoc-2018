defmodule Aoc.D12 do
  def p1(filename) do
    filename
    |> File.read!()
    |> parse_initial_state_and_rules
    |> next_gen(0)
  end

  def parse_initial_state_and_rules(file) do
    [initial_state_string | rules] =
      file
      |> String.split("\n", trim: true)

    [_, initial_state] = String.split(initial_state_string, ": ", trim: true)

    rule_map =
      Enum.map(rules, &String.split(&1, " => ", trim: true))
      |> Enum.reduce(%{}, fn [rule, result], acc ->
        Map.put(acc, String.graphemes(rule), result)
      end)

    {String.graphemes(initial_state), rule_map}
  end

  def next_gen({prev_state, _}, 102 = cur_gen) do
    Enum.reduce(prev_state, {0, -4 * cur_gen}, fn val, {total, i} ->
      if val == "#" do
        {total + i, i + 1}
      else
        {total, i + 1}
      end
    end)
    |> IO.inspect()

    prev_state
  end

  def next_gen({prev_state, rule_map}, cur_gen) do
    IO.inspect(cur_gen)
    IO.inspect(Enum.join(prev_state))

    Enum.reduce(prev_state, {0, -4 * cur_gen}, fn val, {total, i} ->
      if val == "#" do
        {total + i, i + 1}
      else
        {total, i + 1}
      end
    end)
    |> IO.inspect()

    padded = [".", ".", ".", "."] ++ prev_state ++ [".", ".", ".", "."]
    next_gen({Enum.reverse(build_next_gen(padded, rule_map, [])), rule_map}, cur_gen + 1)
  end

  def build_next_gen([_, _, _, _], _, so_far), do: [".", "."] ++ so_far ++ [".", "."]

  def build_next_gen([a, b, c, d, e | rest_pots], rules, so_far) do
    result = Map.get(rules, [a, b, c, d, e], ".")
    build_next_gen([b | [c | [d | [e | rest_pots]]]], rules, [result | so_far])
  end
end
