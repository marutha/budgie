defmodule BudgieWeb.BudgetShowLiveTest do
  use BudgieWeb.ConnCase, async: true

  import Budgie.Factory

  import Phoenix.LiveViewTest

  setup do
    user = Budgie.AccountsFixtures.user_fixture()
    # budget = insert(:budget)

    #     period =
    #       insert(:budget_period, budget: budget, start_date: ~D[2025-01-01], end_date: ~D[2025-01-31])

    #     %{budget: budget, user: budget.creator, period: period, user: user}
    %{user: user}
  end

  describe "Index view" do
    test "Invalid UUID Budget transaction new", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)

      assert {:error, {:redirect, %{to: "/budgets", flash: %{"error" => "Budget not found"}}}} =
               live(conn, ~p"/budgets/#{Ecto.UUID.generate()}/new")
    end

    test "Invalid Budget transaction new", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)

      assert {:error, {:redirect, %{to: "/budgets", flash: %{"error" => "Budget not found"}}}} =
               live(conn, ~p"/budgets/something_else/new")
    end

    test "Valid Budget transaction new", %{conn: conn, user: user} do
      budget = insert(:budget)
      conn = log_in_user(conn, user)

      assert {:ok, _lv, _html} =
               live(conn, ~p"/budgets/#{budget.id}/new")
    end

    test "Valid Budget transaction edit", %{conn: conn, user: user} do
      budget_transaction = insert(:budget_transaction)
      conn = log_in_user(conn, user)

      assert {:ok, _lv, _html} =
               live(
                 conn,
                 ~p"/budgets/#{budget_transaction.budget_id}/transactions/#{budget_transaction.id}/edit"
               )
    end

    test "Valid Budget transaction delete", %{conn: conn, user: user} do
      budget_transaction = insert(:budget_transaction)
      conn = log_in_user(conn, user)

      assert {:ok, lv, _html} =
               live(
                 conn,
                 ~p"/budgets/#{budget_transaction.budget_id}/transactions/#{budget_transaction.id}/edit"
               )

      render_hook(lv, "delete_transaction", %{"id" => budget_transaction.id})
    end

    test "InValid Budget transaction delete", %{conn: conn, user: user} do
      budget_transaction = insert(:budget_transaction_funding)
      conn = log_in_user(conn, user)

      assert {:ok, lv, _html} =
               live(
                 conn,
                 ~p"/budgets/#{budget_transaction.budget_id}/transactions/#{budget_transaction.id}/edit"
               )

      render_hook(lv, "delete_transaction", %{"id" => Ecto.UUID.generate()})
    end

    test "InValid Budget transaction redirect", %{conn: conn, user: user} do
      budget_transaction = insert(:budget_transaction_funding)
      conn = log_in_user(conn, user)

      assert {:ok, lv, _html} =
               live(
                 conn,
                 ~p"/budgets/#{budget_transaction.budget_id}/transactions/#{budget_transaction.id}/edit"
               )

      render_hook(lv, "/budgets/#{budget_transaction.budget_id}", %{})
      assert_redirect(lv, ~p"/budgets/#{budget_transaction.budget_id}")
    end

    test "Valid Budget invalid transaction edit", %{conn: conn, user: user} do
      budget_transaction = insert(:budget_transaction)
      conn = log_in_user(conn, user)

      assert {:error,
              {:redirect,
               %{to: "/budgets" <> _budget_id, flash: %{"error" => "Transaction not found"}}}} =
               live(
                 conn,
                 ~p"/budgets/#{budget_transaction.budget_id}/transactions/some_other_id/edit"
               )
    end

    test "Valid Budget invalid uuid transaction edit", %{conn: conn, user: user} do
      budget_transaction = insert(:budget_transaction)
      conn = log_in_user(conn, user)

      assert {:error,
              {:redirect,
               %{to: "/budgets" <> _budget_id, flash: %{"error" => "Transaction not found"}}}} =
               live(
                 conn,
                 ~p"/budgets/#{budget_transaction.budget_id}/transactions/#{Ecto.UUID.generate()}/edit"
               )
    end

    test "creates transaction on save event", %{conn: conn, user: user} do
      budget = insert(:budget)
      conn = log_in_user(conn, user)
      {:ok, lv, _html} = live(conn, ~p"/budgets/#{budget.id}/new")

      # Simulate form submit that triggers "save"
      params = %{"amount" => "100.00", "type" => "spending", "description" => "Lunch"}

      lv
      |> form("#budget-transaction-form", transaction: params)
      |> render_submit()

      assert_redirect(lv, ~p"/budgets/#{budget.id}")
    end

    # test "redirects after deleting an existing transaction", %{
    #   view: view,
    #   budget: budget,
    #   transaction: transaction
    # } do
    #   # Simulate event
    #   render_hook(view, "delete_transaction", %{"id" => transaction.id})

    #   # Assert deletion in DB
    #   refute Tracking.get_transaction(transaction.id)

    #   # Assert redirect
    #   assert_redirected(view, ~p"/budgets/#{budget.id}")
    #   assert get_flash(view) == %{"info" => "Deleted sucessfully"}
    # end

    # test "redirects even if transaction does not exist", %{conn: conn, view: view, budget: budget} do
    #   render_hook(view, "delete_transaction", %{"id" => Ecto.UUID.generate()})

    #   assert_redirected(view, ~p"/budgets/#{budget.id}")
    #   # assert conn.assigns.flash == %{"info" => "Deleted sucessfully"}
    # end
  end
end
