defmodule PrintingDepartment do
  @moduledoc """
  Documentation for `PrintingDepartment`.
  """

  @doc """
  Method to count the accesible rolls of paper, knowing that they are only accessed when are fewer that four rolls of
  paper in their eight adjacent positions

  ## Examples

      iex> PrintingDepartment.accesible_rolls("files/example.txt")
      13

      iex> PrintingDepartment.accesible_rolls("files/sample.txt")
      1547

  """

  def accesible_rolls(path) do
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

    Enum.map(indexed_rolls, fn roll -> is_accesible?(indexed_rolls, roll) end)
    |> Enum.filter(fn accesible -> accesible == true end)
    |> length
  end

  defp is_accesible?(indexed_rolls, _roll = {_, y, x}) do
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
    |> then(&(&1 < 4))
  end

  def exist_at(cells, y, x) do
    Enum.any?(cells, fn
      {_, ^y, ^x} -> true
      _ -> false
    end)
  end

  @doc """
  Method to count the accesible rolls of paper, knowing that they are only accessed when are fewer that four rolls of
  paper in their eight adjacent positions, and that they can be removed an then recalculated

  ## Examples

      iex> PrintingDepartment.accesible_rolls_by_removing("files/example.txt")
      43

      iex> PrintingDepartment.accesible_rolls_by_removing("files/sample.txt")
      8948

  """
  def accesible_rolls_by_removing(path) do
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

    inaccessible_rolls = remove_accesible_rolls(indexed_rolls)

    length(indexed_rolls) - length(inaccessible_rolls)
  end

  def remove_accesible_rolls(rolls) do
    unaccessible_rolls = Enum.filter(rolls, fn roll -> is_accesible?(rolls, roll) == false end)

    IO.inspect(length(unaccessible_rolls))

    if length(unaccessible_rolls) == length(rolls) do
      unaccessible_rolls
    else
      remove_accesible_rolls(unaccessible_rolls)
    end
  end
end
