defmodule Playground do
  @moduledoc """
  Documentation for `Laboratories`.
  """

  @doc """
  Method to obtain the size of the three largest circuits generated from joining them based on the ones with the
  shortest distance between then

  ## Examples

      iex> Playground.three_largest_circuits_size("files/example.txt", 10)
      40

      iex> Playground.three_largest_circuits_size("files/sample.txt", 1000)
      83520
  """

  def three_largest_circuits_size(path, pairs \\ 10) do
    junction_boxes =
      File.read!(path)
      |> String.split("\r\n", trim: true)
      |> Enum.map(&String.split(&1, ",", trim: true))
      |> Enum.map(fn [x, y, z] ->
        {String.to_integer(x), String.to_integer(y), String.to_integer(z)}
      end)

    junction_pairs =
      Enum.with_index(junction_boxes)
      |> Enum.flat_map(fn {j1, i} ->
        junction_boxes
        |> Enum.drop(i + 1)
        |> Enum.map(fn j2 -> {j1, j2, distance(j1, j2)} end)
      end)
      |> Enum.sort_by(fn {_j1, _j2, dist} -> dist end)
      |> Enum.take(pairs)

    base_junction_map = init_union_find(junction_boxes)

    junction_map =
    junction_pairs
    |> Enum.reduce(base_junction_map, fn {j1, j2, _dist}, acc ->
      union(acc, j1, j2)
    end)

    circuit_sizes =
      junction_boxes
      |> Enum.map(fn box -> find_parent(junction_map, box) end)
      |> Enum.frequencies()
      |> Map.values()

    circuit_sizes
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  defp distance({x1, y1, z1}, {x2, y2, z2}),
    do: :math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) + (z2 - z1) * (z2 - z1))

  def init_union_find(junction_boxes) do
    junction_boxes
    |> Enum.map(fn box -> {box, box} end)
    |> Map.new()
  end

  def find_parent(map, box) do
    parent = Map.get(map, box)

    if parent == box do
      box
    else
      find_parent(map, parent)
    end
  end

  def union(map, box1, box2) do
    root1 = find_parent(map, box1)
    root2 = find_parent(map, box2)

    if root1 == root2 do
      map
    else
      Map.put(map, root1, root2)
    end
  end


end
