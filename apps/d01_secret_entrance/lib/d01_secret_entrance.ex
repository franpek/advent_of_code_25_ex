defmodule SecretEntrance do
  @moduledoc """
  Documentation for `SecretEntrance`.
  """

  @doc """
  ...

  ## Examples

      iex> SecretEntrance.crack_pwd("apps/d01_secret_entrance/files/example.txt")
      3

      iex> SecretEntrance.crack_pwd("apps/d01_secret_entrance/files/sample.txt")
      1150

  """
  def crack_pwd(path) do
    processed_input = File.read!(path)
    |> String.split("\r\n", trim: true)
    |> Enum.map(fn line -> String.split_at(line, 1) end)
    |> Enum.map(fn {letter, number} -> { letter |> String.to_atom  , number |> String.to_integer } end)

    rotate_and_count_zeros(processed_input)
  end

  defp rotate_and_count_zeros(steps, pos \\ 50, acc \\ 0)
  defp rotate_and_count_zeros([], _pos, acc), do: acc
  defp rotate_and_count_zeros([{direction, moves} | rest], pos, acc) do

    new_pos = rotate(direction, moves, pos)
    new_acc = case new_pos do
      0 -> acc + 1
      _ -> acc
    end

    rotate_and_count_zeros(rest, new_pos, new_acc)
  end

  defp rotate(:L, moves, pos), do: Integer.mod(pos + moves, 100)
  defp rotate(:R, moves, pos), do: Integer.mod(pos - moves, 100)

end