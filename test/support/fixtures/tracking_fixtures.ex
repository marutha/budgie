defmodule Budgie.TrackingFixtures do
  def valid_budget_attrs(attrs \\ %{}) do
    attrs
    |> maybe_add_user()
    |> Enum.into(%{
      name: "A test budgie",
      description: "A short description",
      start_date: ~D[2024-01-01],
      end_date: ~D[2025-09-10]
    })
  end

  def budget_fixuture(attrs \\ %{}) do
    {:ok, budget} =
      attrs
      |> valid_budget_attrs()
      |> Budgie.Tracking.create_budget()

    budget
  end

  def maybe_add_user(attrs) when is_map(attrs) do
    Map.put_new_lazy(attrs, :creator_id, fn ->
      user = Budgie.AccountsFixtures.user_fixture()
      user.id
    end)
  end
end
