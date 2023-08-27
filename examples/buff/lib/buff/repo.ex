defmodule Buff.Repo do
  use Ecto.Repo,
    otp_app: :buff,
    adapter: Ecto.Adapters.Postgres
end
