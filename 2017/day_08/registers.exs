defmodule Registers do
  def run(input_path) do
    {regs, max} =
      File.stream!(input_path)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&parse_instruction/1)
      |> Enum.reduce({%{}, 0}, &eval(&1, &2))

    Enum.max_by(regs, fn {_, v} -> v end) |> elem(1) |> IO.inspect # Part 1
    IO.inspect(max) # Part 2
  end

  def parse_instruction(inst) do
    inst
    |> String.split(" ", trim: true, parts: 4)
  end

  def eval([reg, op, val, condition], {regs, m}) do
    case eval_condition(condition, regs) do
      {true, regs} -> do_eval(reg, op, val, regs, m)
      {false, regs} -> {regs, m}
    end
  end

  def do_eval(reg, op, val, regs, m) do
    reg = String.to_atom(reg)
    val = String.to_integer(val)
    {v, regs} = get_or_set(reg, regs)
    res =
      case op do
        "inc" -> v+val
        "dec" -> v-val
      end
    {Map.put(regs, reg, res), update_max(res, m)}
  end

  def update_max(v, m), do: if v > m, do: v, else: m

  def eval_condition(<<_::bytes-size(3), condition::binary>>, regs) do
    reg =
      condition
      |> String.split(" ", trim: true, parts: 2)
      |> hd
      |> String.to_atom

    {_, regs} = get_or_set(reg, regs)
    {res, list} = Code.eval_string(condition, Enum.into(regs, []))
    {res, Enum.into(list, %{})}
  end

  def get_or_set(reg, regs) do
    case regs[reg] do
      nil -> {0, Map.put(regs, reg, 0)}
      v -> {v, regs}
    end
  end
end

"input" |> Registers.run
