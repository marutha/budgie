defmodule BudgieWeb.BudgetShowLive do
  alias Budgie.Tracking.BudgetTransaction
  alias Budgie.Tracking
  use BudgieWeb, :live_view

  @impl true
  def mount(%{"budget_id" => id} = params, _session, socket) when is_uuid(id) do
    budget =
      Tracking.get_budget(id,
        # user: socket.assigns.current_scope.user,
        preload: [:creator, :periods]
      )

    if budget do
      transactions = Tracking.list_transactions(budget)
      summary = Tracking.summarize_budget_transactions(budget)

      {:ok,
       assign(socket,
         budget: budget,
         transactions: transactions,
         summary: summary,
         transaction: default_transaction()
       )
       |> apply_action(params)}
    else
      socket =
        socket
        |> assign(transaction: default_transaction())
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

  def apply_action(%{assigns: %{live_action: :edit_transaction}} = socket, %{
        "transaction_id" => transaction_id
      }) do
    IO.inspect(transaction_id, label: :valid_tx)
    transaction = Enum.find(socket.assigns.transactions, &(&1.id == transaction_id))

    if transaction do
      socket |> assign(transaction: transaction)
    else
      socket
      |> put_flash(:error, "Transaction not found")
      |> assign(transaction: default_transaction())
      |> redirect(to: ~p"/budgets/#{socket.assigns.budget}")
    end
  end

  def apply_action(%{assigns: %{live_action: live_action}} = socket, other) do
    IO.inspect(other, label: :other_action)
    IO.inspect(live_action, label: :other_live_action)
    socket
  end

  @impl true
  def handle_event("/budgets/" <> budget_id, _uri, socket) do
    socket =
      socket
      |> redirect(to: "/budgets/" <> budget_id)

    {:noreply, socket}
  end

  def handle_event("delete_transaction", %{"id" => transaction_id}, socket) do
    transaction = Enum.find(socket.assigns.transactions, &(&1.id == transaction_id))

    socket =
      if transaction do
        case Tracking.delete_transaction(transaction) do
          {:ok, _t} ->
            socket
            |> put_flash(:info, "Deleted sucessfully")
            |> redirect(to: ~p"/budgets/#{socket.assigns.budget}")

          _ ->
            socket
            |> put_flash(:info, "Deleted sucessfully")
            |> redirect(to: ~p"/budgets/#{socket.assigns.budget}")
        end
      else
        socket
        |> put_flash(:info, "Deleted sucessfully")
        |> redirect(to: ~p"/budgets/#{socket.assigns.budget}")
      end

    {:noreply, socket}
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

  defp default_transaction() do
    %BudgetTransaction{effective_date: Date.utc_today()}
  end
end
