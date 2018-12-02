# iex -r 01.ex
# iex> DayOne.partN "01-input.txt"

defmodule DayOne do
  def partOne(str) do
    {:ok, file} = File.read(str)
    String.trim(file) |>
    String.split("\n") |>
    Enum.reduce(0, fn(num, acc) ->
      case Integer.parse(num) do
        :error -> acc
        {parsed, _} -> acc + parsed
      end
    end
    )
  end

  def partTwo(inputFileName) do
    {:ok, file} = File.read(inputFileName)
    String.trim(file) |>
    String.split("\n") |>
    Enum.map(fn (num) ->
      case Integer.parse(num) do
        :error -> nil
        {parsed, _} -> parsed
      end
    end) |>
    processFreqList([0], 0, 0)
  end

  def processFreqList(shiftList, previousFrequencies, curShiftI, curFreq) do
    # IO.puts(curShiftI)
    # IO.puts(curFreq)
    # IO.puts("start over: " <> to_string(curShiftI == Enum.count(shiftList)))
    case curShiftI == Enum.count(shiftList) do
      true -> processFreqList(shiftList, previousFrequencies, 0, curFreq)
      false -> 
        shift = Enum.at(shiftList, curShiftI)
        # IO.puts("shift by" <> String.Chars.Integer.to_string(shift))
        newFreq = curFreq + shift
        # IO.puts(String.Chars.Integer.to_string(newFreq))
        case newFreq in previousFrequencies do
          false -> processFreqList(shiftList, previousFrequencies ++ [newFreq], curShiftI + 1, newFreq)
          true -> newFreq
      end
    end
  end
end
