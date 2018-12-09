defmodule Aoc.Circle do
  def new() do
    {[], []}
  end

  def insert({pre, post}, value), do: {pre, [value | post]}

  # Front of list
  def prev({[], post}) do
    [current | pre] = Enum.reverse(post)
    {pre, [current]}
  end

  # Middle / end of list
  def prev({[value | pre], post}), do: {pre, [value | post]}

  # Empty list
  def next({[], []}), do: []
  # End of list
  def next({pre, [current]}), do: {[], Enum.reverse([current | pre])}
  # Middle of list
  def next({pre, [value | post]}), do: {[value | pre], post}

  def next_by(circle, by) when by == 0, do: circle
  def next_by(circle, by), do: next_by(next(circle), by - 1)

  def prev_by(circle, by) when by == 0, do: circle
  def prev_by(circle, by), do: prev_by(prev(circle), by - 1)

  def remove({pre, [_ | post]}), do: {pre, post}

  def value({_, [current | _]}), do: current

  def to_list({pre, post}), do: Enum.reverse(pre) ++ post
end
