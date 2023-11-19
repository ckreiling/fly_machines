import Config

config :fly_machines, default: [
  base_url: "https://api.machines.dev/v1",
  auth: {:bearer, System.fetch_env!("FLY_API_TOKEN")}
]

