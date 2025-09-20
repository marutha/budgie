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
      assert %{end_date: ["Must be end of the month"]} = errors_on(changeset)
    end

    test "List budgets returns all budgets" do
      budgets = insert_pair(:budget)
      assert Tracking.list_budgets() == without_preloads(budgets)
    end

    test "List budgets with preload criteria" do
      budget = insert(:budget)
      assert Tracking.list_budgets(preload: [:creator]) == [budget]
    end

    test "List budgets with user preload criteria" do
      budget = insert(:budget)
      assert Tracking.list_budgets(user: budget.creator) == without_preloads([budget])
    end

    test "List budgets with invalid preloads" do
      budgets = insert_pair(:budget)
      assert Tracking.list_budgets(some: [:else]) == without_preloads(budgets)
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

    test "List transactions with preload" do
      budget = TrackingFixtures.budget_fixuture()
      attrs = valid_budget_transaction_fixture(%{budget_id: budget.id})

      assert {:ok, %Budgie.Tracking.BudgetTransaction{} = transaction} =
               Tracking.create_transaction(attrs)

      assert [transaction] == without_preloads(Tracking.list_transactions(budget.id, preload: [:budget]))
      assert transaction.effective_date == attrs.effective_date
      assert transaction.amount == attrs.amount
      assert transaction.description == attrs.description
      assert transaction.type == attrs.type
    end

    test "List transactions with invalid preload" do
      budget = TrackingFixtures.budget_fixuture()
      attrs = valid_budget_transaction_fixture(%{budget_id: budget.id})

      assert {:ok, %Budgie.Tracking.BudgetTransaction{} = transaction} =
               Tracking.create_transaction(attrs)

      assert [transaction] == without_preloads(Tracking.list_transactions(budget.id, some: [:budget]))
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

    test "Update budget transaction" do
      budget = TrackingFixtures.budget_fixuture()
      attrs = valid_budget_transaction_fixture(%{budget_id: budget.id})

      assert {:ok, %Budgie.Tracking.BudgetTransaction{} = transaction} =
               Tracking.create_transaction(attrs)

      update_attrs = %{effective_date: ~D[2025-09-11], amount: Decimal.new("100.00"), description: "Updated description"}

      assert {:ok, updated_transaction} = Tracking.update_transaction(transaction, update_attrs)

      assert update_attrs.effective_date == updated_transaction.effective_date
      assert update_attrs.amount == updated_transaction.amount
      assert update_attrs.description == updated_transaction.description
    end

    test "Change budget transaction changeset" do
      budget = TrackingFixtures.budget_fixuture()
      attrs = valid_budget_transaction_fixture(%{budget_id: budget.id})

      assert {:ok, %Budgie.Tracking.BudgetTransaction{} = transaction} =
               Tracking.create_transaction(attrs)

      update_attrs = %{effective_date: ~D[2025-09-11], amount: Decimal.new("100.00"), description: "Updated description"}

      assert %Ecto.Changeset{} = Tracking.change_transaction(transaction, update_attrs)
    end

    test "Delete budget transaction" do
      budget = TrackingFixtures.budget_fixuture()
      attrs = valid_budget_transaction_fixture(%{budget_id: budget.id})

      assert {:ok, %Budgie.Tracking.BudgetTransaction{} = transaction} =
               Tracking.create_transaction(attrs)

      assert {:ok, _tx} = Tracking.delete_transaction(transaction)
      assert [] == Tracking.list_transactions(budget)
    end

    test "Summarize budget transactions" do
      budget = TrackingFixtures.budget_fixuture()
      attrs = valid_budget_transaction_fixture(%{budget_id: budget.id})

      assert {:ok, %Budgie.Tracking.BudgetTransaction{} = _transaction} =
               Tracking.create_transaction(attrs)

      amount = attrs.amount
      # empty = Decimal.new("0.0")

      assert %{spending: ^amount} = Tracking.summarize_budget_transactions(budget.id)
    end

    test "Summarize non existing budget transactions" do
      budget = TrackingFixtures.budget_fixuture()
      # budget = %Budget{id: Ecto.UUID.generate()}
      # empty = Decimal.new("0.0")
      assert %{} = Tracking.summarize_budget_transactions(budget)
    end
  end
end
