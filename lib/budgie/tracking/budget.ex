defmodule Budgie.Tracking.Budget do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "budgets" do
    field :name, :string
    field :description, :string
    field :start_date, :date
    field :end_date, :date

    belongs_to :creator, Budgie.Accounts.User

    has_many :periods, Budgie.Tracking.BudgetPeriod

    timestamps(type: :utc_datetime)
  end

  def changeset(budget, attrs) do
    budget
    |> cast(attrs, [:name, :description, :start_date, :end_date, :creator_id])
    |> validate_required([:name, :start_date, :end_date, :creator_id])
    |> validate_length(:name, max: 100)
    |> validate_length(:description, max: 500)
    |> check_constraint(:end_date,
      name: :budget_end_after_start,
      message: "Must end after start date"
    )
    |> Budgie.Validations.validate_date_month_boundaries()
    |> add_periods()
  end

  def add_periods(%{valid?: false} = changeset), do: changeset

  def add_periods(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    changeset
    |> change(%{periods: months_between(start_date, end_date)})
    |> cast_assoc(:periods)
  end

  def months_between(start_date, end_date, acc \\ []) do
    end_of_month = Date.end_of_month(start_date)

    if not Date.after?(end_date, end_of_month) do
      Enum.reverse([%{start_date: start_date, end_date: end_of_month} | acc])
    else
      months_between(
        Date.add(end_of_month, 1),
        end_date,
        [%{start_date: start_date, end_date: end_of_month} | acc]
      )
    end
  end
end
