defmodule Budgie.Tracking.BudgetTest do
  use Budgie.DataCase

  alias Budgie.Tracking.Budget

  describe "months between/3" do
    test "" do
      start_date = ~D[2025-09-01]
      end_date = ~D[2025-09-30]

      months = Budget.months_between(start_date, end_date)

      assert months == [%{start_date: ~D[2025-09-01], end_date: ~D[2025-09-30]}]
    end

    test "3 months between a quarter range" do
      start_date = ~D[2025-01-01]
      end_date = ~D[2025-03-31]

      months = Budget.months_between(start_date, end_date)

      assert months == [
               %{start_date: ~D[2025-01-01], end_date: ~D[2025-01-31]},
               %{start_date: ~D[2025-02-01], end_date: ~D[2025-02-28]},
               %{start_date: ~D[2025-03-01], end_date: ~D[2025-03-31]}
             ]
    end
  end
end
