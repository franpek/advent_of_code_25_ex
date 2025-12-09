defmodule MovieTheater do
  @moduledoc """
  Documentation for `MovieTheater`.
  """

  @doc """
  Method to get the largest area of any rectangle you can make based on the input
  ## Examples

      iex> MovieTheater.get_largest_area("files/example.txt")
      50

      iex> MovieTheater.get_largest_area("files/sample.txt")
      4735222687
  """

  def solve(path) do
    floor_grid =
      File.read!(path)
      |> String.split("\r\n", trim: true)
      |> Enum.map(&String.split(&1, ",", trim: true))
      |> Enum.map(fn [x, y] ->
        {String.to_integer(x), String.to_integer(y)}
      end)

    rectangles =
      floor_grid
      |> Enum.flat_map(fn tile1 ->
        floor_grid
        |> Enum.map(fn tile2 -> {tile1, tile2, abs(area(tile1, tile2))} end)
      end)

    {_tile1, _tile2, area} =
      Enum.sort_by(rectangles, fn {_tile1, _tile2, area} -> area end, :desc)
      |> hd

    area
  end

  defp area({x1, y1}, {x2, y2}), do: (y2 - y1 + 1) * (x2 - x1 + 1)
end
