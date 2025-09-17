defmodule BudgieWeb.CreateTransactionDialog do
  use BudgieWeb, :live_component

  alias Budgie.Tracking
  alias Budgie.Tracking.BudgetTransaction

  @impl true
  def update(assigns, socket) do
    changeset = Tracking.change_transaction(default_transaction(), %{})

    socket =
      socket
      |> assign(assigns)
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"transaction" => params}, socket) do
    changeset =
      default_transaction()
      |> Tracking.change_transaction(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"transaction" => tx_params}, socket) do
    budget = socket.assigns.budget

    tx_params = Map.put(tx_params, "budget_id", budget.id)

    case Tracking.create_transaction(tx_params) do
      {:ok, transaction} ->
        IO.inspect(transaction, label: "created sucessfully")

        socket =
          socket
          |> push_navigate(to: ~p"/budgets/#{budget}", replace: true)

        {:noreply, socket}

      {:error, changeset} ->
        IO.inspect(changeset, label: "created sucessfully")
        changeset = Map.put(changeset, :action, :validate)
        {:noreply, socket |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset, as: "transaction"))
  end

  defp default_transaction() do
    %BudgetTransaction{effective_date: Date.utc_today()}
  end
end
