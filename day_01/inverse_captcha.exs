defmodule InverseCaptcha do
  def run(p) do
    {:ok, inp} = File.read("day1.input")
    inp = String.trim(inp)
    len = byte_size(inp)
    IO.puts compute_sum(inp, 0, p, len)
  end

  def compute_sum(_, sum, _, n) when n < 1 do
    sum
  end

  def compute_sum(<<curr::bytes-size(1), rest::binary>>, sum, p, n) do
    str = <<rest::binary, curr::binary>>
    next = get_next(str, p)
    sum = if curr == next, do: sum + String.to_integer(next), else: sum
    compute_sum(str, sum, p, n-1)
  end

  def get_next(str, p) do
    case p do
      1 ->
        <<next::bytes-size(1), _rest::binary>> = str
        next
      2 ->
        n = (str |> byte_size |> div(2)) - 1
        <<_::bytes-size(n), next::bytes-size(1), _::binary>> = str
        next
    end
  end
end

InverseCaptcha.run(2)
