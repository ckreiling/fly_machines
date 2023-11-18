# FlyMachines

A minimalist Elixir client for the
[Fly Machines API](https://docs.machines.dev/swagger/index.html), powered by `Req`.

## Installation

This package can be installed by adding `fly_machines` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fly_machines, "~> 0.1"}
  ]
end
```

## Usage

The simplest way to use this client is to pass options to a request function:

```elixir
req_options = [
  base_url: "https://api.machines.dev/v1",
  auth: {:bearer, System.fetch_env!("FLY_API_TOKEN")}
]

FlyMachines.apps_list("personal", req_options)
# {:ok, [%{"name" => "..."}]}
```

For convenience, global client options can be specified in application
configuration:

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

`Req` options passed to client functions are merged in with options specified in
application configuration via the `Req.update/2` function.

## Tokens

It's easiest to retrieve a token using `flyctl`. To get a token for
your `personal` org:

```bash
export FLY_API_TOKEN=$(fly tokens create org "personal")
```
