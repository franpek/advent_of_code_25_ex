defmodule MovieTheater do
  @moduledoc """
  Documentation for `MovieTheater`.
  """

  @doc """
  Method to get the largest area of any rectangle of red tiles you can make based on the input
  ## Examples

      iex> MovieTheater.get_largest_red_tiles_area("files/example.txt")
      50

      iex> MovieTheater.get_largest_red_tiles_area("files/sample.txt")
      4735222687
  """

  def get_largest_red_tiles_area(path) do
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

  defp area({x1, y1}, {x2, y2}), do: (abs(x2 - x1) + 1) * (abs(y2 - y1) + 1)

  @doc """
  Method to get the largest area of any rectangle of red tiles you can make based on the input, considering green ones
  ## Examples

      iex> MovieTheater.get_largest_red_and_green_tiles_area("files/example.txt")
      24

      iex> MovieTheater.get_largest_red_and_green_tiles_area("files/sample.txt")
      1569262188
  """

  def get_largest_red_and_green_tiles_area(path) do
    red_tiles =
      File.read!(path)
      |> String.split("\r\n", trim: true)
      |> Enum.map(&String.split(&1, ",", trim: true))
      |> Enum.map(fn [x, y] ->
        {String.to_integer(x), String.to_integer(y)}
      end)

    indexed_tiles = Enum.with_index(red_tiles)

    rectangles =
      for {tile1, i} <- indexed_tiles,
          {tile2, j} <- indexed_tiles,
          i < j,
          is_rect_inside?(tile1, tile2, red_tiles) do
        {tile1, tile2, area(tile1, tile2)}
      end

    {_tile1, _tile2, max_area} =
      Enum.max_by(rectangles, fn {_tile1, _tile2, area} -> area end)

    max_area
  end

  defp is_rect_inside?({x1, y1}, {x2, y2}, points) do
    x_min = min(x1, x2)
    x_max = max(x1, x2)
    y_min = min(y1, y2)
    y_max = max(y1, y2)

    corners = [
      {x_min, y_min},
      {x_min, y_max},
      {x_max, y_min},
      {x_max, y_max}
    ]

    all_corners_inside = Enum.all?(corners, &is_point_inside?(&1, points))

    if not all_corners_inside do
      false
    else
      rect_edges = [
        {{x_min, y_min}, {x_min, y_max}},
        {{x_min, y_max}, {x_max, y_max}},
        {{x_max, y_max}, {x_max, y_min}},
        {{x_max, y_min}, {x_min, y_min}}
      ]

      polygon_edges = Enum.zip(points, Enum.drop(points, 1) ++ [hd(points)])

      Enum.all?(polygon_edges, fn poly_edge ->
        Enum.all?(rect_edges, fn rect_edge ->
          not lines_intersect?(rect_edge, poly_edge)
        end)
      end)
    end
  end

  defp is_point_inside?({px, py}, points) do
    edges = Enum.zip(points, Enum.drop(points, 1) ++ [hd(points)])

    on_edge =
      Enum.any?(edges, fn {{x1, y1}, {x2, y2}} ->
        is_point_on_line?(px, py, x1, y1, x2, y2)
      end)

    if on_edge do
      true
    else
      intersections =
        Enum.count(edges, fn {{x1, y1}, {x2, y2}} ->
          cond do
            y1 == y2 ->
              false

            y1 > py == y2 > py ->
              false

            true ->
              dy = y2 - y1
              left = (px - x1) * dy
              right = (x2 - x1) * (py - y1)

              if dy > 0 do
                left < right
              else
                left > right
              end
          end
        end)

      rem(intersections, 2) == 1
    end
  end

  defp is_point_on_line?(px, py, x1, y1, x2, y2) do
    cross = (x2 - x1) * (py - y1) - (y2 - y1) * (px - x1)

    cross == 0 and
      px >= min(x1, x2) and px <= max(x1, x2) and
      py >= min(y1, y2) and py <= max(y1, y2)
  end

  defp lines_intersect?({{ax1, ay1}, {ax2, ay2}}, {{bx1, by1}, {bx2, by2}}) do
    if {ax1, ay1} == {bx1, by1} or {ax1, ay1} == {bx2, by2} or
         {ax2, ay2} == {bx1, by1} or {ax2, ay2} == {bx2, by2} do
      false
    else
      o1 = orientation(ax1, ay1, ax2, ay2, bx1, by1)
      o2 = orientation(ax1, ay1, ax2, ay2, bx2, by2)
      o3 = orientation(bx1, by1, bx2, by2, ax1, ay1)
      o4 = orientation(bx1, by1, bx2, by2, ax2, ay2)

      o1 * o2 < 0 and o3 * o4 < 0
    end
  end

  defp orientation(ax, ay, bx, by, cx, cy) do
    val = (bx - ax) * (cy - ay) - (by - ay) * (cx - ax)

    cond do
      val > 0 -> 1
      val < 0 -> -1
      true -> 0
    end
  end
end
