defmodule Factory do
  @moduledoc """
  Solves the Factory initialization puzzle using Gaussian elimination in GF(2).
  """

  def solve(path) do
    machines =
      File.read!(path)
      |> String.split("\r\n", trim: true)
      |> Enum.map(&parse_machine/1)

    machines
    |> Enum.map(&solve_machine/1)
    |> Enum.sum()
  end

  defp parse_machine(machine) do

    parts = String.split(machine, " ", trim: true)

    [indicator_lights | rest] = parts
    button_wirings = Enum.slice(rest, 0..-2//1)

    target = parse_indicator_lights(indicator_lights)
    buttons = Enum.map(button_wirings, &parse_button_wiring/1)

    {target, buttons}
  end

  defp parse_indicator_lights(str) do
    str
    |> String.trim_leading("[")
    |> String.trim_trailing("]")
    |> String.graphemes()
    |> Enum.map(fn
      "." -> 0
      "#" -> 1
    end)
  end

  defp parse_button_wiring(str) do
    str
    |> String.trim_leading("(")
    |> String.trim_trailing(")")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp solve_machine({target, buttons}) do

    num_lights = length(target)
    num_buttons = length(buttons)

    matrix = build_matrix(num_lights, num_buttons, buttons)

    solve_linear_system(matrix, target, num_buttons)
  end

  defp build_matrix(num_lights, num_buttons, buttons) do
    for light <- 0..(num_lights - 1) do
      for button_idx <- 0..(num_buttons - 1) do
        if light in Enum.at(buttons, button_idx), do: 1, else: 0
      end
    end
  end

  # Gaussian elimination in GF(2)
  defp solve_linear_system(matrix, target, num_buttons) do
    # Augment matrix with target vector
    augmented = Enum.zip_with(matrix, target, fn row, t -> row ++ [t] end)

    # Perform Gaussian elimination
    {reduced, pivot_cols} = gaussian_elimination(augmented, num_buttons)

    # Find free variables
    free_vars = Enum.to_list(0..(num_buttons - 1)) -- pivot_cols

    # Try all combinations of free variables to find minimum
    find_minimum_solution(reduced, pivot_cols, free_vars, num_buttons)
  end

  # Gaussian elimination to row echelon form
  defp gaussian_elimination(matrix, num_vars) do
    {final_matrix, pivot_cols} = reduce_matrix(matrix, 0, 0, num_vars, [])
    {final_matrix, Enum.reverse(pivot_cols)}
  end

  defp reduce_matrix(matrix, row, col, num_vars, pivot_cols) do
    if row >= length(matrix) or col >= num_vars do
      {matrix, pivot_cols}
    else
      # Find pivot
      case find_pivot(matrix, row, col) do
        nil ->
          # No pivot in this column, move to next column
          reduce_matrix(matrix, row, col + 1, num_vars, pivot_cols)

        pivot_row ->
          # Swap rows if needed
          matrix = swap_rows(matrix, row, pivot_row)

          # Eliminate column in other rows
          matrix = eliminate_column(matrix, row, col)

          # Move to next row and column
          reduce_matrix(matrix, row + 1, col + 1, num_vars, [col | pivot_cols])
      end
    end
  end

  defp find_pivot(matrix, start_row, col) do
    matrix
    |> Enum.drop(start_row)
    |> Enum.with_index(start_row)
    |> Enum.find(fn {row, _idx} -> Enum.at(row, col) == 1 end)
    |> case do
      nil -> nil
      {_row, idx} -> idx
    end
  end

  defp swap_rows(matrix, i, j) do
    if i == j do
      matrix
    else
      row_i = Enum.at(matrix, i)
      row_j = Enum.at(matrix, j)

      matrix
      |> List.replace_at(i, row_j)
      |> List.replace_at(j, row_i)
    end
  end

  defp eliminate_column(matrix, pivot_row, col) do
    pivot = Enum.at(matrix, pivot_row)

    matrix
    |> Enum.with_index()
    |> Enum.map(fn {row, idx} ->
      if idx != pivot_row and Enum.at(row, col) == 1 do
        xor_rows(row, pivot)
      else
        row
      end
    end)
  end

  defp xor_rows(row1, row2) do
    Enum.zip_with(row1, row2, fn a, b ->
      Bitwise.bxor(a, b)
    end)
  end

  # Find minimum solution by trying all free variable combinations
  defp find_minimum_solution(reduced, pivot_cols, free_vars, num_buttons) do
    if free_vars == [] do
      # No free variables, unique solution
      solution = back_substitute(reduced, pivot_cols, %{}, num_buttons)
      count_ones(solution, num_buttons)
    else
      # Try all combinations of free variables
      num_free = length(free_vars)

      0..(Integer.pow(2, num_free) - 1)
      |> Enum.map(fn combo ->
        # Set free variables based on binary representation
        free_assignments =
          free_vars
          |> Enum.with_index()
          |> Map.new(fn {var, idx} ->
            {var, if(Bitwise.band(combo, Bitwise.bsl(1, idx)) != 0, do: 1, else: 0)}
          end)

        solution = back_substitute(reduced, pivot_cols, free_assignments, num_buttons)
        count_ones(solution, num_buttons)
      end)
      |> Enum.min()
    end
  end

  # Back substitution to find solution
  defp back_substitute(reduced, pivot_cols, free_assignments, num_buttons) do
    pivot_map = pivot_cols |> Enum.with_index() |> Map.new()

    Enum.reduce((length(reduced) - 1)..0//-1, free_assignments, fn row_idx, solution ->
      row = Enum.at(reduced, row_idx)
      col = Enum.at(pivot_cols, row_idx)

      if col do
        # Calculate value for this pivot variable
        target = List.last(row)

        sum =
          Enum.slice(row, (col + 1)..(num_buttons - 1))
          |> Enum.with_index(col + 1)
          |> Enum.reduce(0, fn {coef, var_idx}, acc ->
            Bitwise.bxor(acc, coef * Map.get(solution, var_idx, 0))
          end)

        Map.put(solution, col, Bitwise.bxor(target, sum))
      else
        solution
      end
    end)
  end

  defp count_ones(solution, num_buttons) do
    0..(num_buttons - 1)
    |> Enum.count(fn i -> Map.get(solution, i, 0) == 1 end)
  end
end
