defmodule Checksum do

  def run(input_path, p) do
    File.read!(input_path)
    |> String.split("\n")
    |> Enum.map(fn str -> String.split(str, "\t") end)
    |> Enum.map(fn row -> to_int(row) end)
    |> Enum.reduce(0, fn (row, acc) ->
      case p do
        1 ->
          diff(row) + acc
        2 ->
          divide(row) + acc
      end
    end)
    |> IO.puts
  end

  defp to_int([""]), do: [0]

  defp to_int(row) do
    row
    |> Enum.map(fn s -> String.to_integer(s) end)
  end

  defp diff(row) do
    {min, max} = Enum.min_max(row)
    max - min
  end

  defp divide([0]), do: 0

  defp divide(row) do
    [{x, y}] =
      row
      |> unique_pairs
      |> Stream.map(fn {x, y} -> {max(x, y), min(x, y)} end)
      |> Enum.filter(fn {x, y} -> rem(x, y) == 0 end)

    div(x, y)
  end

  def unique_pairs([a, b]), do: [{a, b}]

  def unique_pairs([h | t]) do
    res = for i <- [h], j <- t, do: {i, j}
    res ++ unique_pairs(t)
  end

end

"input" |> Checksum.run(1)
"input" |> Checksum.run(2)
