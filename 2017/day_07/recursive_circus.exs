defmodule Program do
  defstruct [:name, :weight, :parent, children: []]

  def new(name, weight, children) do
    name = String.to_atom(name)
    weight = parse_weight(weight)
    children = Enum.map(children, &String.to_atom/1)
    %__MODULE__{name: name, weight: weight, children: children}
  end

  def create_or_update(progs, prog) do
    {_, new} =
      Map.get_and_update(progs, prog.name,
        fn cv ->
          case cv do
            nil -> {cv, prog}
            _ -> {cv, %{cv | weight: prog.weight, children: prog.children}}
          end
        end)
    new
  end

  def create_or_update_children(progs, _, []), do: progs

  def create_or_update_children(progs, parent, [child|rest]) do
    {_, new} =
      Map.get_and_update(progs, child,
        fn cv ->
          case cv do
            nil -> {cv, %Program{name: child, parent: parent}}
            _ -> {cv, %{cv | parent: parent}}
          end
        end)
    create_or_update_children(new, parent, rest)
  end

  def root(progs) do
    [{_, prog}] =
      progs
      |> Enum.filter(fn {_, p} -> p.parent == nil end)
    prog
  end

  def total_weight(progs, prog) when is_atom(prog) do
    total_weight(progs, Map.get(progs, prog))
  end

  def total_weight(progs, prog) do
    prog.weight + Enum.reduce(prog.children, 0, fn child, acc -> acc + total_weight(progs, child) end)
  end

  defp parse_weight(str) do
    str
    |> String.replace(~r/[()]/, "")
    |> String.to_integer
  end
end

defmodule RecursiveCircus do
  def run(input_path) do
    progs = read(input_path)
    root = Program.root(progs)
    root.name |> Atom.to_string |> IO.inspect # Part 1
    # progs |> corrected_weight(root) |> IO.inspect # Part 2
  end

  def read(input_path) do
    File.stream!(input_path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.map(&String.split(&1, [" ", ","], trim: true))
    |> construct(%{})
  end

  def construct([], progs), do: progs

  def construct([h | t], progs) do
    {name, weight, children} =
      case h do
        [n, w] -> {n, w, []}
        [n | [w | [_ | c]]] -> {n, w, c}
      end
    prog = Program.new(name, weight, children)
    progs =
      progs
      |> Program.create_or_update(prog)
      |> Program.create_or_update_children(prog.name, prog.children)
    construct(t, progs)
  end

  # def corrected_weight(progs, prog) when is_atom(prog) do
  #   corrected_weight(progs, Map.get(progs, prog))
  # end

  # def corrected_weight(progs, prog) do
  #   children_weights =
  #     prog.children
  #     |> Enum.map(fn prog -> {prog, Program.total_weight(progs, prog)} end)

  #   children_weights |> Enum.uniq_by(fn {_p, w} -> w end)
  # end
end

"test" |> RecursiveCircus.run
