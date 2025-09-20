defmodule Budgie.Tracking.BudgetPeriodTest do
  use Budgie.DataCase

  alias Budgie.Tracking.BudgetPeriod

  describe "Budget period changset test" do
    test "fails if start_date is after the begining of the month" do
      attrs = params_with_assocs(:budget_period, start_date: ~D[2025-09-10])

      changeset = BudgetPeriod.changeset(%BudgetPeriod{}, attrs)

      refute changeset.valid?

      # {:error, _else} = changeset
      assert %{start_date: ["Must be beginning of the month"]} = errors_on(changeset)
    end

    test "Fails if end_date in not end of the month" do
      attrs = params_with_assocs(:budget_period, end_date: ~D[2025-09-10])

      changeset = BudgetPeriod.changeset(%BudgetPeriod{}, attrs)

      refute changeset.valid?
      assert %{end_date: ["Must be end of the month"]} = errors_on(changeset)
    end

    test "Fails if both start_date and end_date in not end of the month" do
      attrs =
        params_with_assocs(:budget_period, start_date: ~D[2025-09-10], end_date: ~D[2025-09-10])

      changeset = BudgetPeriod.changeset(%BudgetPeriod{}, attrs)

      refute changeset.valid?

      # {:error, _else} = changeset
      assert %{
               start_date: ["Must be beginning of the month"],
               end_date: ["Must be end of the month"]
             } = errors_on(changeset)
    end

    test "Valid if both the dates are good" do
      attrs =
        params_with_assocs(:budget_period, start_date: ~D[2025-09-01], end_date: ~D[2025-09-30])

      changeset = BudgetPeriod.changeset(%BudgetPeriod{}, attrs)

      assert changeset.valid?
    end
  end
end
