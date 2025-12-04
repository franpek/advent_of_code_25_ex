defmodule PrintingDepartment do
  @moduledoc """
  Documentation for `PrintingDepartment`.
  """

  @doc """
  Method to count the accesible rolls of paper, knowing that they are only accessed when are fewer that four rolls of paper in their eight adjacent positions

  ## Examples

      iex> PrintingDepartment.solve("files/example.txt")
      13

      iex> PrintingDepartment.solve("files/sample.txt")
      1547

  """

  def solve(path) do
    diagram =
      File.read!(path)
      |> String.split("\r\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    indexed_diagram =
      diagram
      |> Enum.with_index()
      |> Enum.map(fn {row, row_index} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {value, col_index} ->
          {value, row_index, col_index}
        end)
      end)

    indexed_rolls =
      indexed_diagram
      |> List.flatten()
      |> Enum.filter(fn {val, _y, _x} -> val == "@" end)

    Enum.map(indexed_rolls, fn roll -> has_less_than_four_adjacent_rolls(indexed_rolls, roll) end)
    |> Enum.filter(fn exists -> exists == true end)
    |> length
  end

  def has_less_than_four_adjacent_rolls(indexed_rolls, _roll = {_, y, x}) do
    adjacent_rolls =
      [
        exist_at(indexed_rolls, y - 1, x),
        exist_at(indexed_rolls, y - 1, x + 1),
        exist_at(indexed_rolls, y, x + 1),
        exist_at(indexed_rolls, y + 1, x + 1),
        exist_at(indexed_rolls, y + 1, x),
        exist_at(indexed_rolls, y + 1, x - 1),
        exist_at(indexed_rolls, y, x - 1),
        exist_at(indexed_rolls, y - 1, x - 1)
      ]
      |> Enum.filter(fn exists -> exists == true end)
      |> length

    adjacent_rolls < 4
  end

  def exist_at(cells, y, x) do
    Enum.any?(cells, fn
      {_, ^y, ^x} -> true
      _ -> false
    end)
  end

end
