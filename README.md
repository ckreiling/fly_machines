# FlyMachines

A client for the
[Fly Machines API](https://docs.machines.dev/swagger/index.html).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fly_machines` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fly_machines, "~> 0.1"}
  ]
end
```

## Usage

For convenience, common client options can be specified in the application
config. Below is a recommended bare minimum for the `base_url` and `auth`
options:

```elixir
# config/config.exs

config :fly_machines, default: [
  base_url: "https://api.machines.dev/v1",
  auth: {:bearer, System.fetch_env!("FLY_API_TOKEN")}
]

# lib/fly_example.ex

defmodule FlyExample do
  def list_apps do
    FlyMachines.apps_list("personal")
  end
end
```

However it's not required that client config be stored in the application
configuration. Configuration can be sourced from anywhere and passed to any
client function:

```elixir
req_options = [
  base_url: "https://api.machines.dev/v1",
  auth: {:bearer, System.fetch_env!("FLY_API_TOKEN")}
]

FlyMachines.apps_list("personal", req_options)
# {:ok, [%{"name" => "..."}]}
```

`Req` options passed to client functions are merged in to options defined in
application configuration via the `Req.update/2` function.

## Tokens

It's easiest to retrieve a token using `flyctl`. For example to get a token for
the `personal` org:

```bash
export FLY_API_TOKEN=$(fly tokens create org "personal")
```
