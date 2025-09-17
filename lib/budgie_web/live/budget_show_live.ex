defmodule BudgieWeb.BudgetShowLive do
  alias Budgie.Tracking.BudgetTransaction
  alias Budgie.Tracking
  use BudgieWeb, :live_view

  @impl true
  def mount(%{"budget_id" => id}, _session, socket) when is_uuid(id) do
    budget =
      Tracking.get_budget(id,
        # user: socket.assigns.current_scope.user,
        preload: :creator
      )

    if budget do
      transactions = Tracking.list_transactions(budget)
      summary = Tracking.summarize_budget_transactions(budget)
      {:ok, assign(socket, budget: budget, transactions: transactions, summary: summary)}
    else
      socket =
        socket
        |> put_flash(:error, "Budget not found")
        |> redirect(to: ~p"/budgets")

      {:ok, socket}
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> Phoenix.LiveView.put_flash(:error, "Budget not found")
      |> redirect(to: ~p"/budgets")

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <dialog
      open={@live_action == :new_transaction}
      closedby={@live_action != :new_transaction}
      id="create-transactional-modal"
      class="modal"
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
        <.live_component
          module={BudgieWeb.CreateTransactionDialog}
          id="create-transaction"
          budget={@budget}
          return_to={~p"/budgets/#{@budget}"}
        />
      </.focus_wrap>
    </dialog>
    <div class="flex justify-center">
      {@budget.name} by {@budget.creator.name}
    </div>
    <div class="flex justify-between p-6">
      <div class="text-xl">Funding: <.currency amount={@summary.funding} /></div>
      <div class="text-xl">Spending: <.currency class="" amount={@summary.spending} /></div>
      <div class="flex justify-end m-10">
        <.link
          navigate={~p"/budgets/#{@budget}/new-transaction"}
          class="bg-gray-100 text-gray-700"
        >
          <.icon name="hero-plus" class="h-4 w-4" />
          <span>New Transaction</span>
        </.link>
      </div>
    </div>

    <.table id="transactions" rows={@transactions}>
      <:col :let={transaction} label="Description">{transaction.description}</:col>
      <:col :let={transaction} label="Date">{transaction.effective_date}</:col>
      <:col :let={transaction} label="Amount"><.transaction_amount transaction={transaction} /></:col>
    </.table>
    """
  end

  @doc """
    This is the documentation for component function
  """
  attr :transaction, BudgetTransaction, required: true

  def transaction_amount(%{transaction: %{type: :spending, amount: amount}}),
    do: currency(%{amount: Decimal.negate(amount)})

  def transaction_amount(%{transaction: %{type: :funding, amount: amount}}),
    do: currency(%{amount: amount})

  attr :amount, Decimal, required: true
  attr :class, :string, default: nil
  attr :positive_class, :string, default: "text-green-500"
  attr :negative_class, :string, default: "text-red-500"

  def currency(assigns) do
    ~H"""
    <span class={[
      "tabular-nums",
      Decimal.gte?(@amount, 0) && @positive_class,
      Decimal.lt?(@amount, 0) && @negative_class,
      @class
    ]}>
      {Decimal.round(@amount, 2)}
    </span>
    """
  end
end
