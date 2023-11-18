defmodule FlyMachines.Response do
  @moduledoc """
  A struct representing a response from a request.
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
