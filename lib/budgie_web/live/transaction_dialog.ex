defmodule BudgieWeb.TransactionDialog do
  use BudgieWeb, :live_component

  alias Budgie.Tracking

  @impl true
  def update(assigns, socket) do
    changeset = Tracking.change_transaction(assigns.transaction, %{})

    socket =
      socket
      |> assign(assigns)
      |> assign_form(changeset)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"transaction" => params}, socket) do
    changeset =
      socket.assigns.transaction
      |> Tracking.change_transaction(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"transaction" => tx_params}, socket) do
    save_transaction(socket, socket.assigns.action, tx_params)
  end

  defp assign_form(socket, changeset) do
    assign(socket, form: to_form(changeset, as: "transaction"))
  end

  defp save_transaction(socket, :new_transaction, tx_params) do
    budget = socket.assigns.budget

    tx_params = Map.put(tx_params, "budget_id", budget.id)

    case Tracking.create_transaction(tx_params) do
      {:ok, _transaction} ->
        socket =
          socket
          |> push_navigate(to: ~p"/budgets/#{budget}", replace: true)

        {:noreply, socket}

      {:error, changeset} ->
        changeset = Map.put(changeset, :action, :validate)
        {:noreply, socket |> assign_form(changeset)}
    end
  end

  defp save_transaction(socket, :edit_transaction, tx_params) do
    budget = socket.assigns.budget

    tx_params = Map.put(tx_params, "budget_id", budget.id)

    case Tracking.update_transaction(socket.assigns.transaction, tx_params) do
      {:ok, _transaction} ->
        socket =
          socket
          |> push_navigate(to: ~p"/budgets/#{budget}", replace: true)

        {:noreply, socket}

      {:error, changeset} ->
        changeset = Map.put(changeset, :action, :validate)
        {:noreply, socket |> assign_form(changeset)}
    end
  end
end
