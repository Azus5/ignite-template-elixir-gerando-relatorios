defmodule GenReport.Parser do
  @moduledoc """
    Parses a file into an list with lists
  """

  def run(filename) do
    filename
    |> File.stream!()
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> convert_line()
  end

  defp convert_line([name, hours, day, month, year]) do
    [
      String.downcase(name),
      String.to_integer(hours),
      String.to_integer(day),
      month_name(month),
      String.to_integer(year)
    ]
  end

  defp month_name(n) do
    case n do
      "1" -> "janeiro"
      "2" -> "fevereiro"
      "3" -> "março"
      "4" -> "abril"
      "5" -> "maio"
      "6" -> "junho"
      "7" -> "julho"
      "8" -> "agosto"
      "9" -> "setembro"
      "10" -> "outubro"
      "11" -> "novembro"
      "12" -> "dezembro"
    end
  end
end
