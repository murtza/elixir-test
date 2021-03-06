defmodule ExBanking.Account do
  use GenServer

  alias Decimal, as: D



  # Client



  def create_user(user) do
    user = via_tuple(user)
    GenServer.start_link(__MODULE__, %{}, name: user)
  end



  def deposit(user, amount, currency) do
    case user_exists?(user) do
      [] ->
        {:error, :user_does_not_exist}
      [{_, _}] ->
        GenServer.call(via_tuple(user), {:deposit, new_dec(amount), currency})
    end
  end



  def withdraw(user, amount, currency) do
    case user_exists?(user) do
      [] ->
        {:error, :user_does_not_exist}
      [{_, _}] ->
        GenServer.call(via_tuple(user), {:withdraw, new_dec(amount), currency})
    end
  end



  def get_balance(user, currency) do
    case user_exists?(user) do
      [] ->
        {:error, :user_does_not_exist}
      [{_, _}] ->
        GenServer.call(via_tuple(user), {:get_balance, currency})
    end
  end



  # Server



  def init(state) do
    {:ok, state}
  end



  def handle_call({:deposit, amount, currency}, _from, state) do
    if Map.has_key?(state, currency) do
      {_, state} = get_and_update_in(state, [currency], &{&1, D.add(&1, amount)})
      balance = get_in(state, [currency])
      {:reply, {:ok, to_float(balance)}, state}
    else
      {_, state} = get_and_update_in(state, [currency], &{&1, amount})
      balance = get_in(state, [currency])
      {:reply, {:ok, to_float(balance)}, state}
    end
  end



  def handle_call({:withdraw, amount, currency}, _from, state) do
    if Map.has_key?(state, currency) and Map.get(state, currency) >= amount do
      {_, state} = get_and_update_in(state, [currency], &{&1, D.sub(&1, amount)})
      balance = get_in(state, [currency])
      {:reply, {:ok, to_float(balance)}, state}
    else
      {:reply, {:error, :not_enough_money}, state}
    end
  end



  def handle_call({:get_balance, currency}, _from, state) do
    if Map.has_key?(state, currency) do
      balance = get_in(state, [currency])
      {:reply, {:ok, to_float(balance)}, state}
    else
      {:reply, {:ok, 0}, state}
    end
  end



  defp via_tuple(name) do
    {:via, Registry, {:account_registry, name}}
  end



  defp user_exists?(user) do
    Registry.lookup(:account_registry, user)
  end



  def to_float(num) do
    num
    |> D.to_float()
    |> Float.round(2)
  end



  def new_dec(amount) do
    amount / 1
    |> D.new()
  end


end
