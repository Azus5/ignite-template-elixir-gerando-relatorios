defmodule GenReport do
  @moduledoc """
    Generates a report
  """

  alias GenReport.Parser

  def build(), do: {:error, "Insira o nome de um arquivo"}

  def build(filename) when is_nil(filename), do: {:error, "Insira o nome de um arquivo"}

  def build(filename) do
    filename
    |> Parser.run()
    |> Enum.reduce(report_acc(), &sum/2)
  end

  def build_many(file_parts) do
    file_parts
    |> Task.async_stream(&build/1)
    |> Enum.reduce(report_acc(), fn {:ok, result}, acc -> sum_reports(acc, result) end)
  end

  defp sum_reports(acc, result) do
    %{
      all_hours: all_hours_acc,
      hours_per_month: hours_per_month_acc,
      hours_per_year: hours_per_year_acc
    } = acc

    %{
      all_hours: all_hours_result,
      hours_per_month: hours_per_month_result,
      hours_per_year: hours_per_year_result
    } = result

    hours_per_month =
      Map.merge(hours_per_month_acc, hours_per_month_result, fn _k, v1, v2 ->
        merge_maps(v1, v2)
      end)

    hours_per_year =
      Map.merge(hours_per_year_acc, hours_per_year_result, fn _k, v1, v2 -> merge_maps(v1, v2) end)

    %{
      all_hours: merge_maps(all_hours_acc, all_hours_result),
      hours_per_month: hours_per_month,
      hours_per_year: hours_per_year
    }
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _k, value1, value2 -> value1 + value2 end)
  end

  defp sum(data, report) do
    %{
      all_hours: sum_all_hours(data, report[:all_hours]),
      hours_per_month: sum_hours_monthly(data, report[:hours_per_month]),
      hours_per_year: sum_hours_yearly(data, report[:hours_per_year])
    }
  end

  defp sum_all_hours([name, hours, _, _, _], report) do
    key = String.to_atom(name)
    curr_hours = Map.get(report, key, 0)

    Map.put(report, key, curr_hours + hours)
  end

  defp sum_hours_monthly([name, hours, _, month, _], report) do
    person_key = String.to_atom(name)
    month_key = String.to_atom(month)
    person = Map.get(report, person_key, %{})
    month_hours = Map.get(person, month_key, 0)

    person = Map.put(person, month_key, month_hours + hours)
    Map.put(report, person_key, person)
  end

  defp sum_hours_yearly([name, hours, _, _, year], report) do
    person_key = String.to_atom(name)
    person = Map.get(report, person_key, %{})
    year_hours = Map.get(person, year, 0)

    person = Map.put(person, year, year_hours + hours)
    Map.put(report, person_key, person)
  end

  defp report_acc do
    %{
      all_hours: %{},
      hours_per_month: %{},
      hours_per_year: %{}
    }
  end
end
