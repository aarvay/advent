defmodule State do
  defstruct [level: 0, in_garbage?: false, ignore?: false, score: 0]
end

defmodule StreamProcessing do
  def run(input) do
    result =
      File.stream!(input, [], 1)
      |> Enum.reduce(%State{}, &(process(&1, &2)))

    IO.puts result.score # Part 1
  end

  def process(char, state) do
    case state.ignore? do
      true ->
        %{state | ignore?: false}
      false ->
        case state.in_garbage? do
          true ->
            case char do
              ">" -> %{state | in_garbage?: false}
              "!" -> %{state | ignore?: true}
              _ -> state
            end
          false ->
            case char do
              "{" ->
                level = state.level + 1
                score = state.score + level
                %{state | level: level, score: score}
              "}" ->
                %{state | level: state.level - 1}
              "<" ->
                %{state | in_garbage?: true}
              "!" ->
                %{state | ignore?: true}
              _ -> state
            end
        end
    end
  end
end

"input" |> StreamProcessing.run
