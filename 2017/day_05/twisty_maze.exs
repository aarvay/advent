defmodule TwistyMaze do
  def run(input_path, p) do
    File.read!(input_path)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index
    |> Enum.into(%{}, fn {v, k} -> {k, v} end)
    |> solve(0, 0, p)
    |> IO.inspect
  end

  defp solve(maze, pos, res, p) do
    case maze[pos] do
      nil ->
        res
      offset ->
       solve(%{maze | pos => offset + adjust(offset, p)}, pos+offset, res+1, p)
    end
  end

  defp adjust(offset, p) do
    case p do
      1 -> 1
      2 -> if offset > 2, do: -1, else: 1
    end
  end

end

"input" |> TwistyMaze.run(1)
"input" |> TwistyMaze.run(2)
