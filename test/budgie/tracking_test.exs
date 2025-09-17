defmodule Budgie.TrackingTest do
  use Budgie.DataCase

  import Budgie.TrackingFixtures
  alias Budgie.Tracking

  describe "budgets" do
    alias Budgie.Tracking.Budget

    test "Create budget with valid entries" do
      user = Budgie.AccountsFixtures.user_fixture()

      valid_attrs = valid_budget_attrs(%{creator_id: user.id})

      assert {:ok, %Budget{} = budget} = Tracking.create_budget(valid_attrs)
      assert budget.name == "A test budgie"
      assert budget.description == "A short description"
      assert budget.start_date == ~D[2024-01-01]
      assert budget.end_date == ~D[2025-09-10]
      assert budget.creator_id == user.id
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
  end
end
