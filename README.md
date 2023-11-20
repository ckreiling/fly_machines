# FlyMachines

A minimalist Elixir client for the
[Fly Machines API](https://docs.machines.dev/swagger/index.html), powered by
`Req`.

## Installation

This package can be installed by adding `fly_machines` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fly_machines, github: "ckreiling/fly_machines", tag: "0.2.0"}
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

FlyMachines.app_list("personal", req_options)
# {:ok, %FlyMachines.Response{body: [%{"name" => "..."}]}}
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
    FlyMachines.app_list("personal")
  end
end
```

`Req` options passed to client functions are merged in with options specified in
application configuration via the `Req.update/2` function.

### Request Retries

Since this client is implemented on top of `Req`, simply pass the `retry` option
to a request. For example, to ensure a lease is acquired in case of conflict:

```elixir
{:ok, %{body: %{nonce: nonce}}} = FlyMachines.machine_lease_acquire(
  "my-app",
  "my-machine",
  %{ttl: 500},
  retry: fn _req, res -> res.status == 409 end
)

# ... use the nonce in the `fly-machines-lease-nonce` header
```

_This client has retries by default, thanks to `Req`._ For more information, see
the docs for `Req.new/1`.

## Tokens

It's easiest to retrieve a token using `flyctl`. To get a token for your
`personal` org:

```bash
export FLY_API_TOKEN=$(fly tokens create org "personal")
```

## Development

To develop this library you must have Elixir and Erlang installed. It's
recommended to create a `.env` file and `source` it:

```bash
echo '
export MIX_ENV=test
export FLY_TEST_APP_PREFIX=YOUR_TEST_PREFIX
export FLY_TEST_ORG=YOUR_PERSONAL_ORG
export FLY_TEST_REGION="ewr" # use another region than New Jersey, if you want
' > .env

source .env
```

Then you can run:

```bash
mix deps.get
mix deps.compile
mix compile
```

Finally you should have `flyctl` installed and run:

```bash
export FLY_API_TOKEN=$(fly tokens create org "personal")
```

Now you can hop in an IEx session and directly call functions from the
`FlyMachines` module.

### Running Tests

_Run the tests at your own risk._ The only tests for this client are integration
tests, which are disabled by default.

To run all the integration tests:

```bash
mix test --include integration
```

Or run a specific suite of integration tests, since they can take awhile:

```bash
mix test --include integration:apps
mix test --include integration:machines
mix test --include integration:volumes
```

#### Why no Unit Tests?

This client is _minimalist_ in that it has a low surface-area but is flexible
enough to accomplish a lot with.

Some examples of features in more "maximalist" libraries include:

- Pagination support. Lots of APIs require that clients paginate through list
  results, so client implementors usually provide some conveniences to cope with
  it. At time of writing, the Machines API does not have any paginated
  endpoints.
- Marshalling data to/from structs. To avoid having to update the client
  whenever the API evolves, we lob this task to dependents.
- Request retries. This is supported by the underlying `Req` library and
  therefore isn't necessary to test.

### Documentation

Generate documentation for this library simply with:

```bash
export MIX_ENV=docs
mix deps.get
mix deps.compile
mix docs
```

## License

Copyright (c) 2023 Christian Kreiling

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
