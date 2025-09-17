defmodule Budgie.TrackingTest do
  alias Budgie.TrackingFixtures
  use Budgie.DataCase

  import Budgie.TrackingFixtures
  alias Budgie.Tracking

  describe "budgets" do
    alias Budgie.Tracking.Budget

    test "Create budget with valid entries" do
      attrs = params_with_assocs(:budget)
      assert {:ok, %Budget{} = budget} = Tracking.create_budget(attrs)
      assert budget.name == attrs.name
      assert budget.description == attrs.description
      assert budget.start_date == attrs.start_date
      assert budget.end_date == attrs.end_date
      assert budget.creator_id == attrs.creator_id
    end

    test "Create budget requires a name field" do
      user = Budgie.AccountsFixtures.user_fixture()

      attrs =
        valid_budget_attrs(%{creator_id: user.id})
        |> Map.delete(:name)

      assert {:error, %Ecto.Changeset{} = changeset} = Tracking.create_budget(attrs)

      assert changeset.valid? == false
      assert Keyword.keys(changeset.errors) == [:name]
    end

    test "end date must be after start date" do
      user = Budgie.AccountsFixtures.user_fixture()

      invalid_attrs =
        Budget.changeset(
          %Budget{},
          valid_budget_attrs(%{
            start_date: ~D[2025-09-01],
            end_date: ~D[2025-01-01],
            creator_id: user.id
          })
        )

      assert {:error, %Ecto.Changeset{} = changeset} = Budgie.Repo.insert(invalid_attrs)
      assert %{end_date: ["Must end after start date"]} = errors_on(changeset)
    end

    test "List budgets returns all budgets" do
      budgets = insert_pair(:budget)
      assert Tracking.list_budgets() == without_preloads(budgets)
    end

    test "Get specific budget" do
      attrs = params_with_assocs(:budget)
      assert {:ok, %Budget{} = b} = Tracking.create_budget(attrs)
      assert %Budgie.Tracking.Budget{} = budget = Tracking.get_budget(b.id)
      assert budget.name == attrs.name
      assert budget.description == attrs.description
      assert budget.start_date == attrs.start_date
      assert budget.end_date == attrs.end_date
      assert budget.creator_id == attrs.creator_id
    end
  end

  describe "Budget transactions" do
    test "Create budget transaction" do
      budget = TrackingFixtures.budget_fixuture()
      attrs = valid_budget_transaction_fixture(%{budget_id: budget.id})

      assert {:ok, %Budgie.Tracking.BudgetTransaction{} = transaction} =
               Tracking.create_transaction(attrs)

      assert transaction.effective_date == attrs.effective_date
      assert transaction.amount == attrs.amount
      assert transaction.description == attrs.description
      assert transaction.type == attrs.type
    end

    test "List all transactions" do
      budget = TrackingFixtures.budget_fixuture()
      attrs = valid_budget_transaction_fixture(%{budget_id: budget.id})

      assert {:ok, %Budgie.Tracking.BudgetTransaction{} = transaction} =
               Tracking.create_transaction(attrs)

      assert [transaction] == Tracking.list_transactions(budget.id)
      assert transaction.effective_date == attrs.effective_date
      assert transaction.amount == attrs.amount
      assert transaction.description == attrs.description
      assert transaction.type == attrs.type
    end

    test "List specfic budget transaction by budget_id" do
      budget = TrackingFixtures.budget_fixuture()
      attrs = valid_budget_transaction_fixture(%{budget_id: budget.id})

      assert {:ok, %Budgie.Tracking.BudgetTransaction{} = transaction} =
               Tracking.create_transaction(attrs)

      assert [transaction] == Tracking.list_transactions(budget)
      assert transaction.effective_date == attrs.effective_date
      assert transaction.amount == attrs.amount
      assert transaction.description == attrs.description
      assert transaction.type == attrs.type
      assert transaction.budget_id == budget.id
    end

    test "Summarize budget transactions" do
      budget = TrackingFixtures.budget_fixuture()
      attrs = valid_budget_transaction_fixture(%{budget_id: budget.id})

      assert {:ok, %Budgie.Tracking.BudgetTransaction{} = _transaction} =
               Tracking.create_transaction(attrs)

      amount = attrs.amount
      assert %{spending: ^amount} = Tracking.summarize_budget_transactions(budget.id)
    end
  end
end
