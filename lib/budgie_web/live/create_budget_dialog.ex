defmodule BudgieWeb.CreateBudgetDialog do
  use BudgieWeb, :live_component
  # use Phoenix.LiveComponent

  alias Budgie.Tracking
  alias Budgie.Tracking.Budget

  @impl true
  def update(assigns, socket) do
    # Merge assigns (e.g. parent LiveView may pass things like :myself, :id, etc.)
    socket = assign(socket, assigns)

    # Ensure we have a budget struct
    budget = Map.get(socket.assigns, :budget, %Budget{})

    # Ensure we have a form based on that budget
    form =
      case Map.get(socket.assigns, :form) do
        nil -> Tracking.change_budget(budget) |> to_form()
        existing_form -> existing_form
      end

    {:ok, assign(socket, budget: budget, form: form)}
  end

  @impl true
  def handle_event("validate", %{"budget" => budget_params}, socket) do
    changeset =
      socket.assigns.budget
      |> Tracking.change_budget(budget_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"budget" => budget_params}, socket) do
    params = Map.put(budget_params, "creator_id", socket.assigns.current_user.id)

    case Tracking.create_budget(params) do
      {:ok, _budget} ->
        # You can push a patch/redirect or send a message to parent LiveView
        {:noreply,
         socket
         |> put_flash(:info, "Budget created successfully")
         |> redirect(to: ~p"/budgets")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
