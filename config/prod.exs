use Mix.Config

alias ConfexVault.VaultAdapter

config :overseer,
  jwt_key: {{:via, VaultAdapter}, "jwt-key"},
  pagerduty_key: {{:via, VaultAdapter}, "pagerduty-key"},
  twilio_auth_token: {{:via, VaultAdapter}, "twilio-auth-token"},
  enable_pagerduty: true
