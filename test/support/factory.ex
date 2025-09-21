defmodule Budgie.Factory do
  use ExMachina.Ecto, repo: Budgie.Repo

  alias Budgie.Accounts
  alias Budgie.Tracking

  def without_preloads(objects) when is_list(objects), do: Enum.map(objects, &without_preloads/1)
  def without_preloads(%Tracking.Budget{} = budget), do: Ecto.reset_fields(budget, [:creator])

  def without_preloads(%Tracking.BudgetTransaction{} = transaction),
    do: Ecto.reset_fields(transaction, [:budget])

  def user_factory() do
    %Accounts.User{
      name: sequence(:user_name, &"Maru #{&1}"),
      email: sequence(:email, &"maru_#{&1}@m.com"),
      hashed_password: "_"
    }
  end

  def budget_factory() do
    %Tracking.Budget{
      name: sequence(:budget, &"Budget #{&1}"),
      description: sequence(:budget_description, &"Budget Description #{&1}"),
      start_date: ~D[2025-09-01],
      end_date: ~D[2025-09-30],
      creator: build(:user)
    }
  end

  def budget_period_factory() do
    %Tracking.BudgetPeriod{
      start_date: ~D[2025-09-01],
      end_date: ~D[2025-09-30],
      budget: build(:budget)
    }
  end

  def budget_transaction_factory() do
    %Tracking.BudgetTransaction{
      type: "spending",
      amount: Decimal.new("23.23"),
      description: sequence(:transaction_description, &"Transaction description #{&1}"),
      effective_date: ~D[2025-09-01],
      budget: build(:budget)
    }
  end

  def budget_transaction_funding_factory() do
    %Tracking.BudgetTransaction{
      type: "funding",
      amount: Decimal.new("23.23"),
      description: sequence(:transaction_description, &"Transaction description #{&1}"),
      effective_date: ~D[2025-09-01],
      budget: build(:budget)
    }
  end
end
