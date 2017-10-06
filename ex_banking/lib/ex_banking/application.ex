defmodule ExBanking.Application do
  use Application



  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: :account_registry},
      ExBanking.Supervisor
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end



end
