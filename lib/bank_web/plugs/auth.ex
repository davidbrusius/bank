defmodule BankWeb.Plugs.Auth do
  @moduledoc false

  @behaviour Plug

  import Plug.Conn

  alias Bank.{Auth, Users}

  def init(opts), do: opts

  def call(conn, _) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user_id} <- Auth.verify_auth_token(token),
         {:ok, user} <- Users.get_by(:id, user_id) do
      assign(conn, :current_user, Map.take(user, [:id, :email]))
    else
      _ ->
        conn
        |> send_resp(:unauthorized, "Unauthorized")
        |> halt()
    end
  end
end
