defmodule Netwatcher.Repo do
  use Ecto.Repo,
    otp_app: :netwatcher,
    adapter: Ecto.Adapters.SQLite3
end
