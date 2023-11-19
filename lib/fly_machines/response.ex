defmodule FlyMachines.Response do
  @moduledoc """
  A struct representing a Fly Machines API response.

  ## Accessing the `Req.Response`

  The original response from the `Req` library is available in the `req_response` field.
  Most users of this library will not need to access this field, but it is available just in-case.
  """

  @derive {Inspect, except: [:req_response]}
  defstruct [:status, :headers, :body, :req_response]

  @type t :: %__MODULE__{
          status: non_neg_integer(),
          headers: %{binary() => [binary()]},
          body: term(),
          req_response: Req.Response.t()
        }

  @doc false
  def from_req_response(%Req.Response{status: status, body: body, headers: headers} = response) do
    %FlyMachines.Response{
      status: status,
      headers: headers,
      body: body,
      req_response: response
    }
  end
end
