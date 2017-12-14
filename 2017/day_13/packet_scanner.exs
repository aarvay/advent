defmodule Scanner do
  defstruct [range: nil, curr_pos: 1, dir: :forward]

  def move(scanner), do: scanner |> change_pos |> switch_dir

  defp change_pos(scanner) do
    case scanner.dir do
      :forward -> %{scanner | curr_pos: scanner.curr_pos + 1}
      :backward -> %{scanner | curr_pos: scanner.curr_pos - 1}
    end
  end

  defp switch_dir(scanner) do
    case {scanner.curr_pos == 1, scanner.curr_pos == scanner.range} do
      {true, _} -> %{scanner | dir: :forward}
      {_, true} -> %{scanner | dir: :backward}
      _ -> scanner
    end
  end
end

defmodule Layer do
  defstruct [depth: nil, scanner: %Scanner{}]

  def new(%{"depth" => depth, "range" => range}) do
    %Layer{depth: String.to_integer(depth), \
           scanner: %Scanner{range: String.to_integer(range)}}
  end

  def find(layers, depth) do
    layers |> Enum.find(fn layer -> layer.depth == depth end)
  end

  def move_scanner(layer) do
    %{layer | scanner: Scanner.move(layer.scanner)}
  end
end

defmodule State do
  defstruct [layers: [], packet_pos: -1, caught: []]
end

defmodule PacketScanner do
  def run(input) do
    {layers, max} = read(input)
    final_state = %State{layers: layers} |> ride(max)

    final_state.caught
    |> Enum.sum
    |> IO.inspect

    %State{layers: layers} |> find_min_delay(max, 1) |> IO.inspect
  end

  def find_min_delay(state, max, delay) do
    final_state = ride_with_delay(state, max, delay)
    if Enum.empty?(final_state.caught), do: delay, else: find_min_delay(state, max, delay+1)
  end


  def ride_with_delay(state, max, 0), do: ride(state, max)

  def ride_with_delay(state, max, delay) do
    state |> move_scanners |> ride_with_delay(max, delay-1)
  end

  def ride(state, -1), do: state

  def ride(state, max) do
    state |> move_packet |> move_scanners |> ride(max-1)
  end

  def read(input) do
    layers =
      File.read!(input)
      |> String.split("\n", trim: true)
      |> Enum.map(&parse/1)
    max = Enum.max_by(layers, fn l -> l.depth end)

    {layers, max.depth}
  end

  def parse(str) do
    ~r/(?<depth>\d+):\s(?<range>\d+)/
    |> Regex.named_captures(str)
    |> Layer.new
  end

  def move_packet(state) do
    %{state | packet_pos: state.packet_pos + 1} |> check_if_caught
  end

  def check_if_caught(state) do
    case Layer.find(state.layers, state.packet_pos) do
      nil -> state
      layer ->
        if (layer.scanner.curr_pos == 1) do
          %{state | caught: [layer.depth*layer.scanner.range | state.caught]}
        else
          state
        end
    end
  end

  def move_scanners(state) do
    %{state | layers: Enum.map(state.layers, &Layer.move_scanner/1)}
  end
end

"input" |> PacketScanner.run
