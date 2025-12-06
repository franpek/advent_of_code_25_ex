defmodule TrashCompactor do
  @moduledoc """
  Documentation for `TrashCompactor`.
  """

  @doc """
  Method to solve the math worksheet of the cephalopod

  ## Examples

      iex> TrashCompactor.solve_math_worksheet("files/example.txt")
      4277556

      iex> TrashCompactor.solve_math_worksheet("files/sample.txt")
      xxx

  """
  def solve_math_worksheet(path) do
    worksheet_columns =
      File.read!(path)
      |> String.split("\r\n", trim: true)
      |> Enum.map(&String.split(&1, " ", trim: true))
      |> Enum.zip()

    worksheet_columns
    |> Enum.map(&solve_column/1)
    |> Enum.sum()
  end

  defp solve_column(col) do
    [operator | number_string] =
      col
      |> Tuple.to_list()
      |> Enum.reverse()

    numbers =
      number_string
      |> Enum.map(&String.to_integer/1)

    Enum.reduce(numbers, operator_fun(operator))
  end

  def operator_fun("+"), do: &Kernel.+/2
  def operator_fun("*"), do: &Kernel.*/2
end
