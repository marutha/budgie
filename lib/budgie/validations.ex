defmodule Budgie.Validations do
  import Ecto.Changeset

  def validate_date_month_boundaries(%{valid?: false} = cs), do: cs

  def validate_date_month_boundaries(cs) do
    start_date = get_field(cs, :start_date)
    end_date = get_field(cs, :end_date)

    cs =
      if start_date != Date.beginning_of_month(start_date) do
        add_error(cs, :start_date, "Must be beginning of the month")
      else
        cs
      end

    if end_date != Date.end_of_month(end_date) do
      add_error(cs, :end_date, "Must be end of the month")
    else
      cs
    end
  end
end
