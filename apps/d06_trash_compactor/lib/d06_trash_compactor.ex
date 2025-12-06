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
      6417439773370

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

  @doc """
  Method to solve the math worksheet of the cephalopod, knowing that math is written right-to-left in columns

  ## Examples

      iex> TrashCompactor.solve_math_worksheet_correctly("files/example.txt")
      3263827

      iex> TrashCompactor.solve_math_worksheet_correctly("files/sample.txt")
      11044319475191

  """
  def solve_math_worksheet_correctly(path) do
    worksheet_columns =
      File.read!(path)
      |> String.split("\r\n", trim: true)
      |> Enum.map(&String.codepoints/1)
      |> pad_to_max_length()
      |> Enum.zip()
      |> split_on_blank_row

    worksheet_columns
    |> Enum.map(&solve_column_correctly/1)
    |> Enum.sum()
  end

  defp pad_to_max_length(lists) do
    max_len = lists |> Enum.map(&length/1) |> Enum.max()
    Enum.map(lists, fn l -> l ++ List.duplicate(" ", max_len - length(l)) end)
  end

  def split_on_blank_row(list) do
    list
    |> Enum.reduce({[], []}, fn tuple, {acc, current} ->
      if Tuple.to_list(tuple) |> Enum.all?(&(&1 == " ")) do
        {acc ++ [current], []}
      else
        {acc, current ++ [tuple]}
      end
    end)
    |> then(fn {acc, current} ->
      if current != [], do: acc ++ [current], else: acc
    end)
  end

  def solve_column_correctly(col) do
    operator =
      col
      |> hd
      |> Tuple.to_list()
      |> List.last()

    numbers =
      col
      |> Enum.map(fn tuple ->
        tuple
        |> Tuple.to_list()
        # remove spaces and operator
        |> Enum.reject(&(&1 in [" ", "+", "*"]))
        |> Enum.join()
      end)
      |> Enum.map(&String.to_integer/1)

    Enum.reduce(numbers, operator_fun(operator))
  end
end
