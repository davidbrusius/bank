defmodule BankWeb.Router do
  use BankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :ensure_authenticated do
    plug BankWeb.Plugs.Auth
  end

  scope "/api", BankWeb do
    pipe_through :api

    scope "/auth", Auth do
      post "/token", TokenController, :create
    end
  end

  scope "/api", BankWeb do
    pipe_through [:api, :ensure_authenticated]

    resources "/accounts", AccountController, only: [:show], param: "number"
    post "/accounts/transfer", Account.TransferController, :create
  end
end
