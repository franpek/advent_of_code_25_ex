defmodule Lobby do
  @moduledoc """
  Documentation for `Lobby`.
  """

  @doc """
  Method to get from an unrearrangeable bank of batteries, take the two of higher value

  ## Examples

      iex> Lobby.maximum_joltage("files/example.txt")
      357

      iex> Lobby.maximum_joltage("files/sample.txt")
      17443

  """
  def maximum_joltage(path) do
    banks =
      File.read!(path)
      |> String.split("\r\n", trim: true)

    higher_batteries =
      banks
      |> Enum.map(&get_higher_battery_pair/1)

    higher_batteries |> Enum.sum()
  end

  def get_higher_battery_pair(bank) do
    batteries = bank |> String.graphemes() |> Enum.with_index()
    num_of_batteries = batteries |> length

    {n1, n2} =
      Enum.reduce(batteries, {"0", "0"}, fn {bat, bat_idx}, {high_bat_1, high_bat_2} ->
        is_last = bat_idx + 1 == num_of_batteries

        cond do
          high_bat_1 == 0 -> {bat, "0"}
          high_bat_2 == 0 -> {high_bat_1, bat}
          bat > high_bat_1 && not is_last -> {bat, "0"}
          bat > high_bat_2 -> {high_bat_1, bat}
          true -> {high_bat_1, high_bat_2}
        end
      end)

    String.to_integer(n1 <> n2)
  end

  @doc """
  Method to get from an unrearrangeable bank of batteries, take the twelve of higher value
  It is achieved by eliminating low number from left to right

  ## Examples

      iex> Lobby.larger_maximum_joltage("files/example.txt")
      3121910778619

      iex> Lobby.larger_maximum_joltage("files/sample.txt")
      172167155440541

  """
  def larger_maximum_joltage(path) do
    banks =
      File.read!(path)
      |> String.split("\r\n", trim: true)

    higher_batteries =
      banks
      |> Enum.map(&get_higher_battery_dozen/1)

    higher_batteries |> Enum.sum()
  end

  def get_higher_battery_dozen(bank) do

    digits = String.graphemes(bank)
    to_remove = length(digits) - 12

    digits
    |> build_max_number(to_remove)
    |> Enum.join()
    |> String.to_integer()
  end

  defp build_max_number(digits, to_remove) when to_remove <= 0, do: digits

  defp build_max_number(digits, to_remove) do
    IO.inspect(digits)

    {stack_rev, remaining} =
      Enum.reduce(digits, {[], to_remove}, fn d, {stack, rem} ->

        {stack_after_pops, rem_after} = pop_while_smaller(stack, d, rem)
        {[d | stack_after_pops], rem_after}
      end)

    stack = Enum.reverse(stack_rev)
    IO.inspect(stack)

    if remaining > 0 do
      keep = length(stack) - remaining
      Enum.take(stack, keep)
    else
      stack
    end
  end

  defp pop_while_smaller([top | rest], digit, rem) when rem > 0 and top < digit, do: pop_while_smaller(rest, digit, rem - 1)
  defp pop_while_smaller(stack, _digit, rem), do: {stack, rem}
end

