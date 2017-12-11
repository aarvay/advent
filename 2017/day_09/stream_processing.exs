defmodule State do
  defstruct [level: 0, in_garbage?: false, ignore?: false, score: 0, chars: 0]
end

defmodule StreamProcessing do
  def run(input) do
    result =
      File.stream!(input, [], 1)
      |> Enum.reduce(%State{}, &(process(&1, &2)))

    IO.puts result.score # Part 1
    IO.puts result.chars # Part 2
  end

  def process(_, %{ignore?: true} = state), do: %{state | ignore?: false}

  def process(char, %{in_garbage?: true} = state) do
    case char do
      ">" -> %{state | in_garbage?: false}
      "!" -> %{state | ignore?: true}
      _ -> %{state | chars: state.chars + 1}
    end
  end

  def process(char, state) do
    case char do
      "{" ->
        level = state.level + 1
        score = state.score + level
        %{state | level: level, score: score}
      "}" -> %{state | level: state.level - 1}
      "<" -> %{state | in_garbage?: true}
      _ -> state
    end
  end
end

"input" |> StreamProcessing.run
