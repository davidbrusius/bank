defmodule BankWeb.Auth.TokenView do
  use BankWeb, :view

  def render("authorized.json", assigns) do
    %{token: assigns.token}
  end

  def render("unauthorized.json", _assigns) do
    %{error: "Invalid email or password"}
  end
end
