defmodule SecretEntrance do
  @moduledoc """
  Documentation for `SecretEntrance`.
  """

  @doc """
  Method to find the crack the password of the secret entrance, knowing that it is the number of times by applying
  a sequence of rotations it ends on 0

  ## Examples

      iex> SecretEntrance.crack_pwd("files/example.txt")
      3

      iex> SecretEntrance.crack_pwd("files/sample.txt")
      1150

  """
  def crack_pwd(path) do
    processed_input =
      File.read!(path)
      |> String.split("\r\n", trim: true)
      |> Enum.map(fn line -> String.split_at(line, 1) end)
      |> Enum.map(fn {letter, number} ->
        {letter |> String.to_atom(), number |> String.to_integer()}
      end)

    rotate_and_count_zeros(processed_input)
  end

  defp rotate_and_count_zeros(steps, pos \\ 50, acc \\ 0)
  defp rotate_and_count_zeros([], _pos, acc), do: acc

  defp rotate_and_count_zeros([{direction, moves} | rest], pos, acc) do
    new_pos = rotate(direction, moves, pos)

    new_acc =
      case new_pos do
        0 -> acc + 1
        _ -> acc
      end

    rotate_and_count_zeros(rest, new_pos, new_acc)
  end

  defp rotate(:L, moves, pos), do: Integer.mod(pos + moves, 100)
  defp rotate(:R, moves, pos), do: Integer.mod(pos - moves, 100)

  @doc """
  Method to find the crack the password of the secret entrance, knowing that it is the number of times by applying a
  sequence of rotations it passes through 0

  ## Examples

      iex> SecretEntrance.crack_advanced_pwd("files/example.txt")
      6

      iex> SecretEntrance.crack_advanced_pwd("files/sample.txt")
      6738

  """
  def crack_advanced_pwd(path) do
    rotations =
      File.read!(path)
      |> String.split("\r\n", trim: true)
      |> Enum.map(fn line -> String.split_at(line, 1) end)
      |> Enum.map(&format_rotation/1)

    process_rotations(rotations)
  end

  defp format_rotation({"L", number_str}), do: String.to_integer(number_str) * -1
  defp format_rotation({"R", number_str}), do: String.to_integer(number_str)

  defp process_rotations(rotations, pos \\ 50, acc \\ 0)
  defp process_rotations([], _pos, acc), do: acc

  defp process_rotations([rotation | left_rotations], pos, acc) do
    net_new_pos = pos + rotation
    real_new_pos = Integer.mod(net_new_pos, 100)

    travelled_zeros =
      cond do
        net_new_pos == 0 ->
          1

        net_new_pos > 99 ->
          floor(net_new_pos / 100)

        net_new_pos < 0 ->
          cond do
            pos == 0 -> floor(abs(net_new_pos) / 100)
            true -> floor(abs(net_new_pos) / 100) + 1
          end

        true ->
          0
      end

    IO.puts(
      "From #{pos} the dial is rotated #{rotation} to point at #{real_new_pos}; #{if travelled_zeros >= 1 do
        "during this rotation, it points at cero: #{travelled_zeros} times."
      end}"
    )

    process_rotations(left_rotations, real_new_pos, acc + travelled_zeros)
  end
end
