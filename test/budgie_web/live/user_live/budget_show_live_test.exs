defmodule BudgieWeb.BudgetShowLiveTest do
  use BudgieWeb.ConnCase, async: true

  # use Budgie.DataCase

  import Phoenix.LiveViewTest
  import Budgie.TrackingFixtures

  alias BudgieWeb.BudgetShowLive

  setup do
    user = Budgie.AccountsFixtures.user_fixture()
    # budget = insert(:budget)

    #     period =
    #       insert(:budget_period, budget: budget, start_date: ~D[2025-01-01], end_date: ~D[2025-01-31])

    #     %{budget: budget, user: budget.creator, period: period, user: user}
    %{user: user}
  end

  describe "Index view" do
    test "Shows budget when exists", %{conn: conn, user: user} do
      budget = budget_fixuture()

      conn = log_in_user(conn, user)
      {:ok, _lv, html} = live(conn, ~p"/budgets/#{budget.id}")

      assert html =~ budget.name
    end

    test "Redirects budget when does not exists", %{conn: conn, user: user} do

      budget_id = Ecto.UUID.generate()
      conn = log_in_user(conn, user)
      # {:ok, _lv, html} = live(conn, ~p"/budgets/#{budget_id}")

      {:ok, conn} =
              live(conn, ~p"/budgets/#{budget_id}")
              |> follow_redirect(conn, ~p"/budgets")
      # assert html =~ "Not found"
    end

    test "Shows budget when budget is non-uuid", %{conn: conn, user: user} do

      conn = log_in_user(conn, user)

      {:ok, conn} =
              live(conn, ~p"/budgets/some_thing_junk")
              |> follow_redirect(conn, ~p"/budgets")
    end
  end
end
