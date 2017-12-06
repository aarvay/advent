defmodule MemRealloc do
  def run(input_path) do
    mem = read(input_path)
    {all_configs, repeated_config} = realloc(mem, %{0 => mem}, 0)
    prev =
      all_configs
      |> Enum.find(fn {_, v} -> v == repeated_config end)
      |> elem(0)
    steps = Enum.count(all_configs)

    IO.puts steps # Part 1
    IO.puts steps-prev # Part 2
  end

  defp read(input_path) do
    File.read!(input_path)
    |> String.split("\t", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index(1)
    |> Enum.into(%{}, fn {v, k} -> {k, v} end)
  end

  defp realloc(curr, seen, count) do
    {index, val} = max(curr)
    next = distribute(%{curr | index => 0}, next(index), val)
    count = count + 1

    case Enum.member?(Map.values(seen), next) do
      true ->
        {seen, next}
      _ ->
        seen = Map.put(seen, count, next)
        realloc(next, seen, count)
    end
  end

  defp distribute(mem, _, 0), do: mem

  defp distribute(mem, i, v) do
    distribute(%{mem | i => mem[i] + 1}, next(i), v-1)
  end

  defp next(i) when i >= 16, do: 1
  defp next(i), do: i + 1

  defp max(mem), do: Enum.max_by(mem, fn {_, v} -> v end)

end

"input" |> MemRealloc.run()
