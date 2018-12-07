defmodule Aoc.D7 do
  alias Aoc.Utils

  @doc """
  iex> Aoc.D7.p1("inputs/07-input.txt")
  "BITRAQVSGUWKXYHMZPOCDLJNFE"
  """
  def p1(filename) do
    {tree, steps_to_resolve} =
      filename
      |> File.read!()
      |> Utils.parseLinesFromFile()
      |> Enum.map(&parse_line_to_instruction/1)
      |> build_dep_tree(%{}, MapSet.new())

    resolve_dep_order(steps_to_resolve, tree, [])
  end

  def p2(filename) do
    {tree, steps_to_resolve} =
      filename
      |> File.read!()
      |> Utils.parseLinesFromFile()
      |> Enum.map(&parse_line_to_instruction/1)
      |> build_dep_tree(%{}, MapSet.new())
      |> IO.inspect()

    resolve_dep_order_p2(
      steps_to_resolve,
      tree,
      [],
      [
        {:idle, "", -1},
        {:idle, "", -1},
        {:idle, "", -1},
        {:idle, "", -1},
        {:idle, "", -1}
      ],
      0
    )
  end

  def resolve_dep_order_p2(_, tree, _, workers, total) when tree == %{} do
    {_, _, duration} = Enum.find(workers, fn {status, _, _} -> status == :working end)
    total + duration
  end

  def resolve_dep_order_p2(available_steps, tree, resolved, workers, total) do
    # IO.inspect(resolved, label: total)
    # IO.inspect(tree, label: "tree")

    {new_tree, new_workers, new_available_steps, new_resolved} =
      Enum.reduce(workers, {tree, [], available_steps, resolved}, &handle_finished_workers/2)

    {final_workers, final_steps} =
      Enum.reduce(new_workers, {[], new_available_steps}, &assign_steps_to_workers/2)

    debug_string = Enum.reduce(final_workers, "", &build_debug_string/2)

    IO.inspect(
      debug_string <>
        "      " <>
        Enum.join(Enum.reverse(new_resolved)) <> "         " <> Enum.join(new_available_steps),
      label: total
    )

    resolve_dep_order_p2(Enum.sort(final_steps), new_tree, new_resolved, final_workers, total + 1)
  end

  def build_debug_string({:idle, _, _}, acc) do
    acc <> " " <> "."
  end

  def build_debug_string({_, letter, _}, acc) do
    acc <> " " <> letter
  end

  @doc """
  iex> Aoc.D7.get_duration("A")
  60
  iex> Aoc.D7.get_duration("C")
  62
  """
  def get_duration(step), do: 59 + (:binary.first(step) - 64)

  def assign_steps_to_workers(worker, {workers, []}), do: {[worker | workers], []}

  def assign_steps_to_workers({:idle, _, _}, {workers, [head | tail]}) do
    {[{:working, head, get_duration(head)} | workers], tail}
  end

  def assign_steps_to_workers({:working, _, _} = worker, {workers, steps}),
    do: {[worker | workers], steps}

  def handle_finished_workers({:idle, _, _} = worker, {tree, workers, steps, resolved}),
    do: {tree, [worker | workers], steps, resolved}

  def handle_finished_workers({:working, step, 0}, {tree, workers, steps, resolved}) do
    {new_tree, next_steps} = resolve_dep(step, tree)
    {new_tree, [{:idle, "", -1} | workers], next_steps ++ steps, [step | resolved]}
  end

  def handle_finished_workers({:working, step, time}, {tree, workers, steps, resolved}),
    do: {tree, [{:working, step, time - 1} | workers], steps, resolved}

  @doc """
  iex> Aoc.D7.parse_line_to_instruction("Step C must be finished before step A can begin.")
  {"C", "A"}
  """
  def parse_line_to_instruction(line) do
    [_, dep, parent, _] =
      String.split(line, ["Step ", " must be finished before step ", " can begin."])

    {dep, parent}
  end

  @doc """
  # iex(8)> Aoc.D7.build_dep_tree([{"C", "A"}, {"C", "F"}, {"A", "B"}, {"A", "D"}, {"B", "E"}, {"D", "E"}, {"F", "E"}], %{}, MapSet.new())
  # {%{
  #  "A" => #MapSet<["C"]>,
  #  "B" => #MapSet<["A"]>,
  #  "D" => #MapSet<["A"]>,
  #  "E" => #MapSet<["B", "D", "F"]>,
  #  "F" => #MapSet<["C"]>
  # }
  # }, ["C"]}
  """
  def build_dep_tree([{dep, parent} | tail], tree, known_steps) do
    known_steps = MapSet.put(known_steps, dep) |> MapSet.delete(parent)

    build_dep_tree(
      tail,
      Map.update(tree, parent, MapSet.new([dep]), &MapSet.put(&1, dep)),
      known_steps
    )
  end

  def build_dep_tree([], tree, known_steps) do
    steps_to_resolve =
      MapSet.to_list(known_steps)
      |> Enum.filter(fn key -> not Map.has_key?(tree, key) end)
      |> Enum.sort()

    {tree, steps_to_resolve}
  end

  def resolve_dep_order([], _, resolved) do
    # [{last_key, _}] = Map.to_list(tree)
    # Enum.join(Enum.reverse([last_key | resolved]))
    Enum.join(Enum.reverse(resolved))
  end

  def resolve_dep_order([head | tail], tree, resolved) do
    {new_tree, next_steps} = resolve_dep(head, tree)
    resolve_dep_order(Enum.sort(next_steps ++ tail), new_tree, [head | resolved])
  end

  @doc """
  Aoc.D7.resolve_dep("B", %{"A" => MapSet.new(["B"]), "C" => MapSet.new(["B", "D"])})
  # {%{"C" => #MapSet<["D"]>}, ["A"]}
  """
  def resolve_dep(dep, tree) do
    Enum.filter(tree, fn {_, val} -> dep in val end)
    |> Enum.map(&{&1, dep})
    |> Enum.reduce({tree, []}, &remove_resolved_dep/2)
  end

  @doc """
  # iex> Aoc.D7.remove_resolved_dep({{"A", MapSet.new(["B"])}, "B"}, {%{"A" => MapSet.new(["B"])}, []})
  # {%{}, ["A"]}
  # iex> Aoc.D7.remove_resolved_dep({{"A", MapSet.new(["B"])}, "B"}, {%{"A" => MapSet.new(["B"])}, []})
  # {%{"A" => #MapSet<["B"]>, "C" => #MapSet<["D"]>}, []}
  """
  def remove_resolved_dep({{key, deps}, dep_to_remove}, {tree, next_steps}) do
    if MapSet.size(deps) == 1 do
      {Map.delete(tree, key), [key | next_steps]}
    else
      {Map.put(tree, key, MapSet.delete(deps, dep_to_remove)), next_steps}
    end
  end
end
