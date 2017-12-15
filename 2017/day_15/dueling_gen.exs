defmodule DuelingGen do
  def run do
    {618, 814}
    |> Stream.iterate(&gen/1)
    |> Stream.take(40000000)
    |> Stream.map(&in_binary/1)
    |> Stream.filter(&match?/1)
    |> Enum.count
    |> IO.inspect
  end

  defp gen({num1, num2}), \
    do: {rem(num1*16807, 2147483647), rem(num2*48271, 2147483647)}

  defp match?({<<_::bytes-size(16), x::bytes>>, <<_::bytes-size(16), y::bytes>>}), \
    do: x == y

  defp in_binary({num1, num2}) do: {to_bin(num1), to_bin(num2)}

  defp to_bin(num), \
    do: num |> Integer.to_string(2) |> String.pad_leading(32, "0")
end

DuelingGen.run
