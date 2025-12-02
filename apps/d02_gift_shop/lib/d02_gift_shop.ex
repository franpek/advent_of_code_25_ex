defmodule GiftShop do
  @moduledoc """
  Documentation for `GiftShop`.
  """

  @doc """
  Method to sum the invalid ids located sequence of ranges, knowing that the invalid ones are the palindromic

  ## Examples

      iex> GiftShop.sum_invalid_ids("files/example.txt")
      1227775554

      iex> GiftShop.sum_invalid_ids("files/sample.txt")
      xxx

  """
  def sum_invalid_ids(path) do
    range_ids =
      File.read!(path)
      |> String.split(",", trim: true)
      |> Enum.map(fn range -> String.split(range, "-", trim: true) |> List.to_tuple() end)
      |> Enum.map(fn {first_id, second_id} ->
        String.to_integer(first_id)..String.to_integer(second_id)
      end)
      |> IO.inspect()

    range_ids
    |> Enum.map(&filter_invalid_ids/1)
    |> List.flatten()
    |> Enum.sum()
  end

  def filter_invalid_ids(range), do: Enum.filter(range, fn id -> not is_valid(id) end)

  def is_valid(num), do: !is_palindromic(num)

  def is_palindromic(num) do
    num_string = Integer.to_string(num)
    num_length = String.length(num_string)

    {first_half, second_half} =
      String.split_at(num_string, div(num_length, 2))

    first_half == second_half
  end
end
