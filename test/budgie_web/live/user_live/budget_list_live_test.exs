defmodule BudgieWeb.BudgetListLiveTest do
  use BudgieWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Budgie.TrackingFixtures

  setup do
    user = Budgie.AccountsFixtures.user_fixture()
    %{user: user}
  end

  describe "Index view" do
    test "Shows budget when exists", %{conn: conn, user: user} do
      budget = budget_fixuture()

      conn = log_in_user(conn, user)
      {:ok, _lv, html} = live(conn, ~p"/budgets")

      assert html =~ budget.name
      assert html =~ budget.description
    end

    test "New budget", %{conn: conn, user: user} do
      budget = budget_fixuture()

      conn = log_in_user(conn, user)
      {:ok, _lv, html} = live(conn, ~p"/budgets/new")

    end
  end
end
