defmodule Cafeteria do
  @moduledoc """
  Documentation for `Cafeteria`.
  """

  @doc """
  Method to count get the number of fresh ingredients based on the new cafeteria's database, which has ranges of
  fresh ingredients and a list of available ones

  ## Examples

      iex> Cafeteria.count_available_fresh_ingredients("files/example.txt")
      3

      iex> Cafeteria.count_available_fresh_ingredients("files/sample.txt")
      712

  """
  def count_available_fresh_ingredients(path) do
    ingredient_database =
      File.read!(path)
      |> String.split("\r\n\r\n")
      |> Enum.map(&String.split(&1, "\r\n"))

    available_ing =
      ingredient_database
      |> tl
      |> hd
      |> Enum.map(&String.to_integer/1)

    fresh_ing_ranges =
      ingredient_database
      |> hd
      |> Enum.map(&format_range/1)
      |> Enum.sort()
      |> Enum.reduce([], &reduce_merging_ranges/2)

    Enum.count(available_ing, fn n ->
      Enum.any?(fresh_ing_ranges, fn range -> n in range end)
    end)
  end

  defp format_range(string_range) do
    string_range
    |> String.split("-")
    |> (fn [x, y] -> String.to_integer(x)..String.to_integer(y) end).()
  end

  defp reduce_merging_ranges(range, ranges_acc) do
    case ranges_acc do
      [] ->
        [range]

      _ ->
        [last_range | previous_ranges] = ranges_acc

        range_start..range_end = range
        last_range_start..last_range_end = last_range

        {merge_result, merged_range} =
          merge_range({range_start, range_end}, {last_range_start, last_range_end})

        cond do
          merge_result == :exclusive ->
            [range | ranges_acc]

          merge_result == :overlaps ->
            [merged_range | previous_ranges]
        end
    end
  end

  defp merge_range({range_start, range_end}, {last_range_start, last_range_end}) do
    if (range_start > last_range_end && range_end > last_range_end) ||
         (range_start < last_range_start && range_end < last_range_start) do
      {:exclusive, nil}
    else
      new_start =
        cond do
          range_start <= last_range_start -> range_start
          true -> last_range_start
        end

      new_end =
        cond do
          range_end >= last_range_end -> range_end
          true -> last_range_end
        end

      {:overlaps, new_start..new_end}
    end
  end

  @doc """
  Method to count get the number of registered fresh ingredients based on the new cafeteria's database, taking only into
  account the ranges of defined fresh ones, not the available

  ## Examples

      iex> Cafeteria.count_fresh_ingredients("files/example.txt")
      14

      iex> Cafeteria.count_fresh_ingredients("files/sample.txt")
      332998283036769

  """
  def count_fresh_ingredients(path) do
    ingredient_database =
      File.read!(path)
      |> String.split("\r\n\r\n")
      |> Enum.map(&String.split(&1, "\r\n"))

    fresh_ing_ranges =
      ingredient_database
      |> hd
      |> Enum.map(&format_range/1)
      |> Enum.sort()
      |> Enum.reduce([], &reduce_merging_ranges/2)

    fresh_ing_ranges
    |> Enum.map(&Enum.count/1)
    |> Enum.sum()
  end
end
