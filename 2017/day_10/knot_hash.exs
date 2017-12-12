defmodule KnotHash do
  def run(input) do
    [x, y] =
      File.read!(input)
      |> String.split([",", "\n"], trim: true)
      |> Enum.map(&String.to_integer/1)
      |> process(0..255, 0, 0)
      |> Enum.take(2)

    IO.puts x*y # Part 1
  end

  defp process([], list, _, _), do: list

  defp process([h | t], list, start, skip_size) do
    list = reverse_slice(list, start, h)
    next =
      if (tot = start+h+skip_size) >= 256, do: tot - 256, else: tot
    process(t, list, next, skip_size + 1)
  end

  defp reverse_slice(list, start, count) when (start+count > 256) do
    take = start+count-256
    rem = Enum.slice(list, take..start-1)
    {last, first} =
      Enum.slice(list, start..255) ++ Enum.take(list, take)
      |> Enum.reverse
      |> Enum.split(256-start)
    Enum.concat([first, rem, last])
  end

  defp reverse_slice(list, start, count), do: Enum.reverse_slice(list, start, count)
end

"input" |> KnotHash.run
