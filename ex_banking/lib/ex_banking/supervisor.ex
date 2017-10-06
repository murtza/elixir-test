defmodule ExBanking.Supervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: :bank_supervisor)
  end


  def init(_) do
    Supervisor.init([], [strategy: :one_for_one])
  end


  def create_user(user) do
    case start_child(user) do
      {:ok, _} -> :ok
      {:error, _} -> {:error, :user_already_exists}
    end
  end

  defp start_child(user) do
    Supervisor.start_child(:bank_supervisor, %{
      id: user, restart: :permanent, shutdown: 5000,
      start: {ExBanking.Account, :create_user, [user]}, type: :worker
    })
  end




end
