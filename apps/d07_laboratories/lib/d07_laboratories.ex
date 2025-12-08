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

  @doc """
  Method to count the number of 'quantum' beam splits (timelines)

  ## Examples

      iex> Laboratories.count_timelines("files/example.txt")
      40

      iex> Laboratories.count_timelines("files/sample.txt")
      xxx
  """

  def count_timelines(path) do
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

    visited = MapSet.new()
    memo = %{}

    {result, _final_memo} = count_paths_memo(start_pos, visited, splitters, height, width, memo)
    result
  end

  defp count_paths_memo(position = {y, x}, visited, splitters, height, width, memo) do
    cond do
      y >= height or x < 0 or x >= width ->
        {1, memo}

      MapSet.member?(visited, position) ->
        {0, memo}

      Map.has_key?(memo, position) ->
        {Map.get(memo, position), memo}

      MapSet.member?(splitters, position) ->
        new_visited = MapSet.put(visited, position)

        {left_count, memo1} =
          count_paths_memo({y, x - 1}, new_visited, splitters, height, width, memo)

        {right_count, memo2} =
          count_paths_memo({y, x + 1}, new_visited, splitters, height, width, memo1)

        total = left_count + right_count
        new_memo = Map.put(memo2, position, total)
        {total, new_memo}

      true ->
        new_visited = MapSet.put(visited, position)

        {count, new_memo} =
          count_paths_memo({y + 1, x}, new_visited, splitters, height, width, memo)

        new_memo = Map.put(new_memo, position, count)
        {count, new_memo}
    end
  end
end
