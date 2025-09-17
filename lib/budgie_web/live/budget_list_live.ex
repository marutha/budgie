defmodule BudgieWeb.BudgetListLive do
  alias Budgie.Tracking
  use BudgieWeb, :live_view
  import BudgieWeb.CoreComponents

  @impl true
  def mount(_params, _session, socket) do
    budgets = Tracking.list_budgets() |> Budgie.Repo.preload(:creator)
    {:ok, assign(socket, :budgets, budgets)}
  end

  @impl true
  def handle_event("/budgets", _unsigned_params, socket) do
    socket =
      socket |> redirect(to: "/budgets")

    {:noreply, socket}
  end

  @impl true
  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <dialog
      open={@live_action == :new}
      closedby={@live_action == nil}
      class="modal border-blue border-solid border-2"
      phx-mounted={
        JS.ignore_attributes("open")
        |> JS.transition({"ease-in duration-200", "opacity-0", "opacity-100"}, time: 0)
      }
      phx-remove={
        JS.remove_attribute("open")
        |> JS.transition({"ease-out duration-200", "opacity-100", "opacity-0"}, time: 0)
      }
    >
      <.focus_wrap
        id="container"
        phx-key="escape"
        class="modal-box w-11/12 max-w-2xl"
      >
        <div class="flex justify-end">
          <button
            type="button"
            class="btn btn-sm btn-circle btn-ghost"
            phx-click={JS.push(~p"/budgets")}
          >
            ✕
          </button>
        </div>
        <.live_component
          module={BudgieWeb.CreateBudgetDialog}
          id="create-budget"
          current_user={@current_scope.user}
          return_to={~p"/budgets"}
        />
      </.focus_wrap>
    </dialog>

    <div class="flex justify-end m-10">
      <.link
        navigate={~p"/budgets/new"}
        class="bg-gray-100 text-gray-700"
      >
        <.icon name="hero-plus" class="h-4 w-4" />
        <span>New Budget</span>
      </.link>
    </div>
    <.table id="budgets" rows={@budgets}>
      <:col :let={budget} label="Name">{budget.name}</:col>
      <:col :let={budget} label="Description">{budget.description}</:col>
      <:col :let={budget} label="Start Date">{budget.start_date}</:col>
      <:col :let={budget} label="End Date">{budget.end_date}</:col>
      <:col :let={budget} label="Creator Name">{budget.creator.name}</:col>
      <:col :let={budget} label="Actions"><.link navigate={~p"/budgets/#{budget}"}>View</.link></:col>
    </.table>
    """
  end
end
