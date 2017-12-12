defmodule KnotHash do
  use Bitwise, skip_operators: true

  def run(input, p) do
    lengths = get_lengths(input, p)

    case p do
      1 -> part1(lengths)
      2 -> part2(lengths)
    end
  end

  defp part1(lengths) do
    [x, y] =
      lengths
      |> multi_process(0..255, 0, 0, 1)
      |> Enum.take(2)
    x*y
  end

  defp part2(lengths) do
    lengths
    |> multi_process(0..255, 0, 0, 64)
    |> Enum.chunk_every(16)
    |> Enum.map(fn chunk -> Enum.reduce(chunk, &bxor/2) end)
    |> Enum.map(&to_hex/1)
    |> IO.chardata_to_string
    |> String.downcase
  end

  defp get_lengths(input, 1) do
    File.read!(input)
    |> String.split([",", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp get_lengths(input, 2) do
    File.read!(input)
    |> String.trim
    |> String.to_charlist
    |> Kernel.++([17, 31, 73, 47, 23])
  end

  defp multi_process(_, list, _, _, 0), do: list

  defp multi_process(lengths, list, start, skip_size, round) do
    {list2, start2, skip_size2} = process(lengths, list, start, skip_size)
    multi_process(lengths, list2, start2, skip_size2, round-1)
  end

  defp process([], list, start, skip_size), do: {list, start, skip_size}

  defp process([h | t], list, start, skip_size) do
    list = reverse_slice(list, start, h)
    next = get_next_pos(start+h+skip_size)
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

  defp get_next_pos(pos) when (pos < 256), do: pos
  defp get_next_pos(pos), do: get_next_pos(pos-256)

  defp to_hex(int) do
    int16 = Integer.to_charlist(int, 16)
    if Enum.count(int16) == 1, do: [?0 | int16], else: int16
  end
end

"input" |> KnotHash.run(1) |> IO.inspect
"input" |> KnotHash.run(2) |> IO.inspect
