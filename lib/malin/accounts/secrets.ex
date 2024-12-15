defmodule Malin.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Malin.Accounts.User, _opts) do
    Application.fetch_env(:malin, :token_signing_secret)
  end
end
