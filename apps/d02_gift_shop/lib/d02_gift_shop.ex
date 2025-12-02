defmodule GiftShop do
  @moduledoc """
  Documentation for `GiftShop`.
  """

  @doc """
  Method to sum the invalid ids located sequence of ranges, knowing that the invalid ones have an even number of digits
  and their right and left side are equal

  ## Examples

      iex> GiftShop.sum_invalid_ids("files/example.txt")
      1227775554

      iex> GiftShop.sum_invalid_ids("files/sample.txt")
      38310256125

  """
  def sum_invalid_ids(path) do
    range_ids_sequences =
      File.read!(path)
      |> String.split(",", trim: true)
      |> Enum.map(fn range -> String.split(range, "-", trim: true) |> List.to_tuple() end)
      |> Enum.map(fn {first_id, second_id} ->
        String.to_integer(first_id)..String.to_integer(second_id)
      end)

    range_ids_sequences
    |> Enum.map(&filter_invalid_ids/1)
    |> List.flatten()
    |> Enum.sum()
  end

  defp filter_invalid_ids(range), do: Enum.filter(range, fn id -> invalid?(id) end)

  defp invalid?(num), do: repeated_halves?(num)

  defp repeated_halves?(num) do
    num_string = Integer.to_string(num)
    num_length = String.length(num_string)

    {first_half, second_half} =
      String.split_at(num_string, div(num_length, 2))

    first_half == second_half
  end

  @doc """
  Method to sum the really invalid ids located sequence of ranges, knowing that the invalid ones are a sequence of
  digits repeated at least twice

  ## Examples

      iex> GiftShop.sum_really_invalid_ids("files/example.txt")
      4174379265

      iex> GiftShop.sum_really_invalid_ids("files/sample.txt")
      58961152806

  """
  def sum_really_invalid_ids(path) do
    range_ids_sequences =
      File.read!(path)
      |> String.split(",", trim: true)
      |> Enum.map(fn range -> String.split(range, "-", trim: true) |> List.to_tuple() end)
      |> Enum.map(fn {first_id, second_id} ->
        String.to_integer(first_id)..String.to_integer(second_id)
      end)

    range_ids_sequences
    |> Enum.map(&filter_really_invalid_ids/1)
    |> List.flatten()
    |> Enum.sum()
  end

  defp filter_really_invalid_ids(range), do: Enum.filter(range, fn id -> really_invalid?(id) end)

  defp really_invalid?(id), do: deep_repeated_halves?(id)

  defp deep_repeated_halves?(id) do
    id_string = Integer.to_string(id)

    # A list with the possible parts the id can be divided on to check repeated sequences of digits
    id_divisible_parts = id_string |> id_divisible_parts

    id_divisible_parts
    |> Enum.any?(&are_all_parts_equal_in_sequences_of?(id_string, &1))
  end

  defp id_divisible_parts(id_string) do
    id_length = String.length(id_string)

    1..id_length
    |> Enum.filter(fn part_len ->
      rem(id_length, part_len) == 0 and div(id_length, part_len) >= 2
    end)
  end

  defp are_all_parts_equal_in_sequences_of?(id_string, sequence) do
    repeats = div(String.length(id_string), sequence)

    id_string
    |> String.graphemes()
    |> Enum.chunk_every(sequence)
    |> Enum.take(repeats)
    |> case do
      [] -> false
      [first | rest] -> Enum.all?(rest, &(&1 == first))
    end
  end
end
