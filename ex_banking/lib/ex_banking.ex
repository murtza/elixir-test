defmodule ExBanking do

  alias ExBanking.Account

  @type banking_error :: {:error,
      :wrong_arguments                |
      :user_already_exists            |
      :user_does_not_exist            |
      :not_enough_money               |
      :sender_does_not_exist          |
      :receiver_does_not_exist        |
      :too_many_requests_to_user      |
      :too_many_requests_to_sender    |
      :too_many_requests_to_receiver
    }



  @spec create_user(user :: String.t) :: :ok | banking_error
  def create_user(user) when is_binary(user) do
    ExBanking.Supervisor.create_user(user)
  end
  def create_user(_), do: {:error, :wrong_arguments}



  @spec deposit(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | banking_error
  def deposit(user, amount, currency)
  when is_binary(user) and is_number(amount) and amount > 0 and is_binary(currency) do
    Account.deposit(user, amount, currency)
  end
  def deposit(_, _, _), do: {:error, :wrong_arguments}



  @spec withdraw(user :: String.t, amount :: number, currency :: String.t) :: {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency)
  when is_binary(user) and is_number(amount) and amount > 0 and is_binary(currency) do
    Account.withdraw(user, amount, currency)
  end
  def withdraw(_, _, _), do: {:error, :wrong_arguments}



  @spec get_balance(user :: String.t, currency :: String.t) :: {:ok, balance :: number} | banking_error
  def get_balance(user, currency) when is_binary(user) and is_binary(currency) do
    Account.get_balance(user, currency)
  end
  def get_balance(_, _), do: {:error, :wrong_arguments}



  @spec send(from_user :: String.t, to_user :: String.t, amount :: number, currency :: String.t) :: {:ok, from_user_balance :: number, to_user_balance :: number} | banking_error
  def send(from_user, to_user, amount, currency)
  when is_binary(from_user) and is_binary(to_user) and from_user != to_user and is_number(amount) and amount > 0 and is_binary(currency) do
    case user_exists?(from_user) do
      [] ->
        {:error, :sender_does_not_exist}
      [_] ->
        case user_exists?(to_user) do
          [] ->
            {:error, :receiver_does_not_exist}
          [_] ->
            {:ok, balance1} = Account.withdraw(from_user, amount, currency)
            {:ok, balance2} = Account.deposit(to_user, amount, currency)
            {:ok, balance1, balance2}
        end
    end
  end
  def send(_,_,_,_), do: {:error, :wrong_arguments}



  defp user_exists?(user) do
    Registry.lookup(:account_registry, user)
  end


end
