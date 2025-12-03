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
end
