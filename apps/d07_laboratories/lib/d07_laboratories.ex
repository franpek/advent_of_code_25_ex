defmodule Laboratories do
  @moduledoc """
  Documentation for `Laboratories`.
  """

  @doc """
  Method to count the number of beam splits

  ## Examples

      iex> Laboratories.count_beam_splits("files/example.txt")
      21

      iex> Laboratories.count_beam_splits("files/sample.txt")
      1658
  """

  def count_beam_splits(path) do
    diagram =
      File.read!(path)
      |> String.split("\r\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    height = length(diagram)
    width = length(hd(diagram))

    indexed_diagram = index_matrix(diagram)

    start_pos =
      indexed_diagram
      |> Enum.flat_map(& &1)
      |> Enum.find_value(fn
        {"S", row, col} -> {row, col}
        _ -> nil
      end)

    splitters =
      indexed_diagram
      |> List.flatten()
      |> Enum.filter(fn {val, _y, _x} -> val == "^" end)
      |> Enum.map(fn {_val, y, x} -> {y, x} end)
      |> MapSet.new()

    queue = :queue.from_list([start_pos])
    visited = MapSet.new()

    process_beams(queue, visited, splitters, 0, height, width)
  end

  defp index_matrix(diagram) do
    diagram
    |> Enum.with_index()
    |> Enum.map(fn {row, row_index} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {value, col_index} ->
        {value, row_index, col_index}
      end)
    end)
  end

  defp process_beams(queue, visited, splitters, count, height, width) do
    case :queue.out(queue) do
      {:empty, _} ->
        count

      {{:value, {y, x}}, new_queue} ->
        cond do
          y >= height or x < 0 or x >= width ->
            process_beams(new_queue, visited, splitters, count, height, width)

          MapSet.member?(visited, {y, x}) ->
            process_beams(new_queue, visited, splitters, count, height, width)

          MapSet.member?(splitters, {y, x}) ->
            new_visited = MapSet.put(visited, {y, x})

            new_queue =
              new_queue
              |> then(&:queue.in({y + 1, x - 1}, &1))
              |> then(&:queue.in({y + 1, x + 1}, &1))

            process_beams(new_queue, new_visited, splitters, count + 1, height, width)

          true ->
            new_visited = MapSet.put(visited, {y, x})
            new_queue = :queue.in({y + 1, x}, new_queue)
            process_beams(new_queue, new_visited, splitters, count, height, width)
        end
    end
  end
end
