defmodule Passphrase do
  def run(input_path, p) do
    File.read!(input_path)
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&validate(&1, p))
    |> Enum.sum
    |> IO.puts
  end

  def validate(phrase, p) do
    words = String.split(phrase, " ")

    sort = fn str ->
      str |> String.graphemes |> Enum.sort
    end

    case p do
      1 ->
        if Enum.uniq(words) == words, do: 1, else: 0
      2 ->
        if Enum.uniq_by(words, &sort.(&1)) == words, do: 1, else: 0
    end
  end
end

"input" |> Passphrase.run(1)
"input" |> Passphrase.run(2)
