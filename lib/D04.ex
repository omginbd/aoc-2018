defmodule Aoc.D4 do
  alias Aoc.Utils

  @doc """
  iex> Aoc.D4.p1("inputs/04-test.txt")
  {240, "10", 24}
  """
  def p1(filename) do
    {guardId, minute} =
      filename
      |> File.read!()
      |> Utils.parseLinesFromFile()
      |> nextState(%{}, nil, nil, nil, nil)
      |> findWorstGuard()

    {String.to_integer(guardId) * minute, guardId, minute}
  end

  @doc """
  iex> Aoc.D4.p2("inputs/04-test.txt")
  {4455, "99", 45}
  """
  def p2(filename) do
    {id, {minute, total}} =
      filename
      |> File.read!()
      |> Utils.parseLinesFromFile()
      |> nextState(%{}, nil, nil, nil, nil)
      |> findWorstGuardP2()

    {String.to_integer(id) * minute, id, minute}
  end

  @doc """
  iex> Aoc.D4.findWorstGuardP2(%{"1" => %{1 => 1, 2 => 2, 3 => 1}, "2" => %{1 => 0, 2 => 0, 3 => 3}})
  {"2", 3}
  """
  def findWorstGuardP2(schedules) do
    Enum.reduce(schedules, {0, {0, 0}}, &compareGuardsP2/2)
  end

  def compareGuardsP2(
        {currentId, currentSchedule},
        {worstId, {worstMinute, worstTotal}} = worstSoFar
      ) do
    {curMinute, curTotal} = Enum.max_by(currentSchedule, fn {_, val} -> val end)

    case curTotal > worstTotal do
      true -> {currentId, {curMinute, curTotal}}
      false -> worstSoFar
    end
  end

  @doc """
  iex> Aoc.D4.findWorstGuard(%{"1" => %{1 => 1, 2 => 2, 3 => 1}, "2" => %{1 => 0, 2 => 0, 3 => 3}})
  {"1", 2}
  """
  def findWorstGuard(schedules) do
    {id, total} = Enum.reduce(schedules, {0, 0}, &compareGuards/2)

    {worstMinute, _} =
      Map.get(schedules, id)
      |> Enum.max_by(fn {_, val} -> val end)

    {id, worstMinute}
  end

  def compareGuards({currentId, currentSchedule}, {worstId, worstNum} = worstSoFar) do
    total = Enum.reduce(currentSchedule, 0, fn {_, num}, currentTotal -> currentTotal + num end)

    case total > worstNum do
      true -> {currentId, total}
      false -> worstSoFar
    end
  end

  def processEntries({:sleep, time}, entries, acc, id, :new, curTime, curDate) do
    nextState(
      entries,
      updateGuardSchedule(acc, id, 0..(time - 1), :wake),
      id,
      :sleep,
      time,
      curDate
    )
  end

  def processEntries({:sleep, time}, entries, acc, id, :wake, curTime, curDate) do
    nextState(
      entries,
      updateGuardSchedule(acc, id, curTime..(time - 1), :wake),
      id,
      :sleep,
      time,
      curDate
    )
  end

  def processEntries({:wake, time}, entries, acc, id, curState, curTime, curDate) do
    nextState(
      entries,
      updateGuardSchedule(acc, id, curTime..(time - 1), :sleep),
      id,
      :wake,
      time,
      curDate
    )
  end

  def processEntries({:new, date, newId}, entries, acc, _, _, _, _) do
    nextState(entries, acc, newId, :new, 0, date)
  end

  def nextState([entry | rest], acc, id, curState, curTime, curDate) do
    parseLine(entry)
    |> processEntries(rest, acc, id, curState, curTime, curDate)
  end

  def nextState([], acc, _, _, _, _) do
    acc
  end

  def updateGuardSchedule(acc, id, range, action) do
    Map.put(
      acc,
      id,
      Enum.reduce(range, Map.get(acc, id, %{}), fn minute, schedule ->
        updateMinute(schedule, minute, action)
      end)
    )
  end

  def updateMinute(schedule, minute, :sleep) do
    Map.put(schedule, minute, Map.get(schedule, minute, 0) + 1)
  end

  def updateMinute(schedule, minute, :wake) do
    Map.put(schedule, minute, Map.get(schedule, minute, 0))
  end

  @doc """
  iex> Aoc.D4.parseLine("[1518-02-05 00:00] Guard #3109 begins shift")
  {:new, ~D[1518-02-05], "3109"}
  iex> Aoc.D4.parseLine("[1518-02-05 00:50] falls asleep")
  {:sleep, 50}
  iex> Aoc.D4.parseLine("[1518-02-05 00:54] wakes up")
  {:wake, 54}
  """
  def parseLine(line) do
    case classifyLine(line) do
      :new ->
        [_, year, month, day, id] =
          Regex.run(~r/\[(\d+)-(\d+)-(\d+) \d+:\d+\] Guard #(\d+)/, line)

        {:ok, date} =
          Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day))

        {:new, date, id}

      :sleep ->
        [_, time] = Regex.run(~r/\[\d+-\d+-\d+ \d+:(\d+)\]/, line)
        {:sleep, String.to_integer(time)}

      :wake ->
        [_, time] = Regex.run(~r/\[\d+-\d+-\d+ \d+:(\d+)\]/, line)
        {:wake, String.to_integer(time)}
    end
  end

  def classifyLine(line) do
    case String.match?(line, ~r/begins/) do
      true ->
        :new

      false ->
        case String.match?(line, ~r/falls/) do
          true -> :sleep
          false -> :wake
        end
    end
  end
end
