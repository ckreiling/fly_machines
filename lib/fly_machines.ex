defmodule FlyMachines do
  @moduledoc """
  A minimalist client for the Fly Machines API.

  Each function in this module maps to a single API endpoint. 
  Functions can return any of the following:

  - `{:ok, %Req.Response{}}` - The request succeeded (status code >=200, <300).
  - `{:error, %Req.Response{}}` - The request failed (status code outside 200-range).
  - `{:error, exception}` - The request failed due to a lower-level network error.
  """

  @doc """
  List all apps within an organization.

  ## Examples

      iex> FlyMachines.app_list("personal")
      {:ok, %Req.Response{status: 200}}
  """
  def app_list(org_slug, req_overrides \\ []) when is_binary(org_slug) do
    req_overrides
    |> from_config()
    |> Req.get(url: "/apps", params: [org_slug: org_slug])
    |> convert_to_error()
  end

  @doc """
  Create an App.

  ## Examples

      iex> FlyMachines.app_create(%{org_slug: "personal", name: "my-app"})
      {:ok, %Req.Response{status: 200}}
  """
  def app_create(body, req_overrides \\ []) when is_map(body) do
    req_overrides
    |> from_config()
    |> Req.post(url: "/apps", json: body)
    |> convert_to_error()
  end

  @doc """
  Delete an App.

  Also destroys machines and volumes associated with the app.

  ## Examples

      iex> FlyMachines.app_delete("my-app")
      {:ok, %Req.Response{status: 200}}
  """
  def app_delete(app_name, req_overrides \\ []) when is_binary(app_name) do
    req_overrides
    |> from_config()
    |> Req.delete(url: "/apps/:app", path_params: [app: app_name])
    |> convert_to_error()
  end

  @doc """
  Retrieve an App.

  ## Examples

      iex> FlyMachines.app_retrieve("my-app")
      {:ok, %Req.Response{status: 200}}
  """
  def app_retrieve(app_name, req_overrides \\ []) when is_binary(app_name) do
    req_overrides
    |> from_config()
    |> Req.get(url: "/apps/:app", path_params: [app: app_name])
    |> convert_to_error()
  end

  @doc """
  List machines within an App.

  ## Examples

      iex> FlyMachines.machine_list("my-app")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_list(app_name, req_overrides \\ [])
      when is_binary(app_name) do
    req_overrides
    |> from_config()
    |> Req.get(url: "/apps/:app/machines", path_params: [app: app_name])
    |> convert_to_error()
  end

  @doc """
  Create a machine.

  ## Examples

      iex> FlyMachines.machine_create("my-app", %{config: %{image: "flyio/hellofly"}})
      {:ok, %Req.Response{status: 200}}
  """
  def machine_create(app_name, body, req_overrides \\ [])
      when is_binary(app_name) and is_map(body) do
    req_overrides
    |> from_config()
    |> Req.post(
      url: "/apps/:app/machines",
      path_params: [app: app_name],
      json: body
    )
    |> convert_to_error()
  end

  @doc """
  Update a machine.

  Must include the full machine configuration, not just the fields to update.

  ## Examples

      iex> FlyMachines.machine_update("my-app", "machine-id", %{config: %{image: "flyio/hellofly"}})
      {:ok, %Req.Response{status: 200}}
  """
  def machine_update(app_name, machine_id, body, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) and is_map(body) do
    req_overrides
    |> from_config()
    |> Req.post(
      url: "/apps/:app/machines/:machine_id",
      path_params: [app: app_name, machine_id: machine_id],
      json: body
    )
    |> convert_to_error()
  end

  @doc """
  Retrieve a machine.

  ## Examples

      iex> FlyMachines.machine_retrieve("my-app", "machine-id")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_retrieve(app_name, machine_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) do
    req_overrides
    |> from_config()
    |> Req.get(
      url: "/apps/:app/machines/:machine_id",
      path_params: [app: app_name, machine_id: machine_id]
    )
    |> convert_to_error()
  end

  @doc """
  Delete/destroy a machine. The machine must first be in the `stopped` state.

  ## Examples

      iex> FlyMachines.machine_delete("my-app", "machine-id")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_delete(app_name, machine_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) do
    req_overrides
    |> from_config()
    |> Req.delete(
      url: "/apps/:app/machines/:machine_id",
      path_params: [app: app_name, machine_id: machine_id]
    )
    |> convert_to_error()
  end

  @doc """
  Retrieve metadata map for a machine.

  ## Examples

      iex> FlyMachines.machine_metadata_retrieve("my-app", "machine-id")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_metadata_retrieve(app_name, machine_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) do
    req_overrides
    |> from_config()
    |> Req.get(
      url: "/apps/:app/machines/:machine_id/metadata",
      path_params: [app: app_name, machine_id: machine_id]
    )
    |> convert_to_error()
  end

  @doc """
  Delete a machine metadata key.

  ## Examples

      iex> FlyMachines.machine_metadata_delete("my-app", "machine-id", "key")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_metadata_delete(app_name, machine_id, key, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) and is_binary(key) do
    req_overrides
    |> from_config()
    |> Req.delete(
      url: "/apps/:app/machines/:machine_id/metadata/:key",
      path_params: [app: app_name, machine_id: machine_id, key: key]
    )
    |> convert_to_error()
  end

  @doc """
  List all processes for a machine.

  ## Examples

      iex> FlyMachines.machine_ps("my-app", "machine-id")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_ps(app_name, machine_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) do
    req_overrides
    |> from_config()
    |> Req.get(
      url: "/apps/:app/machines/:machine_id/ps",
      path_params: [app: app_name, machine_id: machine_id]
    )
    |> convert_to_error()
  end

  @doc """
  Start a machine.

  ## Examples

      iex> FlyMachines.machine_start("my-app", "machine-id")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_start(app_name, machine_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) do
    req_overrides
    |> from_config()
    |> Req.post(
      url: "/apps/:app/machines/:machine_id/start",
      path_params: [app: app_name, machine_id: machine_id]
    )
    |> convert_to_error()
  end

  @doc """
  Stop a machine.

  ## Examples

      iex> FlyMachines.machine_stop("my-app", "machine-id")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_stop(app_name, machine_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) do
    req_overrides
    |> from_config()
    |> Req.post(
      url: "/apps/:app/machines/:machine_id/stop",
      path_params: [app: app_name, machine_id: machine_id]
    )
    |> convert_to_error()
  end

  @doc """
  Restart a machine.

  ## Examples

      iex> FlyMachines.machine_restart("my-app", "machine-id")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_restart(app_name, machine_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) do
    req_overrides
    |> from_config()
    |> Req.post(
      url: "/apps/:app/machines/:machine_id/restart",
      path_params: [app: app_name, machine_id: machine_id]
    )
    |> convert_to_error()
  end

  @doc """
  Cordon a machine.

  ## Examples

      iex> FlyMachines.machine_cordon("my-app", "machine-id")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_cordon(app_name, machine_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) do
    req_overrides
    |> from_config()
    |> Req.post(
      url: "/apps/:app/machines/:machine_id/cordon",
      path_params: [app: app_name, machine_id: machine_id]
    )
    |> convert_to_error()
  end

  @doc """
  Wait for a machine to reach a particular state.

  ## Example

      iex> params = [state: "started", timeout: 120]
      iex> FlyMachines.wait_for_machine("my-app", "machine-id", params: params)
      {:ok, %Req.Response{status: 200}}
  """
  def wait_for_machine(app_name, machine_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) do
    req_overrides
    |> from_config()
    |> Req.get(
      url: "/apps/:app/machines/:machine_id/wait",
      path_params: [app: app_name, machine_id: machine_id]
    )
    |> convert_to_error()
  end

  @doc """
  List all versions of a machine.

  ## Examples

      iex> FlyMachines.machine_versions_list("my-app", "machine-id")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_versions_list(app_name, machine_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) do
    req_overrides
    |> from_config()
    |> Req.get(
      url: "/apps/:app/machines/:machine_id/versions",
      path_params: [app: app_name, machine_id: machine_id]
    )
    |> convert_to_error()
  end

  @doc """
  Uncordon a machine.

  ## Examples

      iex> FlyMachines.machine_uncordon("my-app", "machine-id")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_uncordon(app_name, machine_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) do
    req_overrides
    |> from_config()
    |> Req.post(
      url: "/apps/:app/machines/:machine_id/uncordon",
      path_params: [app: app_name, machine_id: machine_id]
    )
    |> convert_to_error()
  end

  @doc """
  Acquire a machine lease.

  ## Examples

      iex> {:ok, %{body: %{"nonce" => nonce}}} = FlyMachines.machine_lease_acquire("my-app", "machine-id")
      iex> {:ok, _} = FlyMachines.machine_update("my-app", "machine-id", %{config: %{image: "flyio/hellofly"}}, headers: [fly_machine_lease_nonce: nonce]])
      iex> FlyMachines.machine_lease_release("my-app", "machine-id", "lease-nonce")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_lease_acquire(app_name, machine_id, body, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) and is_map(body) do
    req_overrides
    |> from_config()
    |> Req.post(
      url: "/apps/:app/machines/:machine_id/lease",
      path_params: [app: app_name, machine_id: machine_id],
      json: body
    )
    |> convert_to_error()
  end

  @doc """
  Release a machine lease.

  ## Examples

      iex> FlyMachines.machine_lease_release("my-app", "machine-id", "lease-nonce")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_lease_release(app_name, machine_id, lease_nonce, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) and is_binary(lease_nonce) do
    req_overrides
    |> from_config()
    |> Req.delete(
      url: "/apps/:app/machines/:machine_id/lease",
      path_params: [app: app_name, machine_id: machine_id],
      headers: [fly_machine_lease_nonce: lease_nonce]
    )
    |> convert_to_error()
  end

  @doc """
  Send a signal to a machine.

  ## Examples

      iex> FlyMachines.machine_signal("my-app", "machine-id", %{signal: "SIGTERM"})
      {:ok, %Req.Response{status: 200}}
  """
  def machine_signal(app_name, machine_id, body, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) and is_map(body) do
    req_overrides
    |> from_config()
    |> Req.post(
      url: "/apps/:app/machines/:machine_id/signal",
      path_params: [app: app_name, machine_id: machine_id],
      json: body
    )
    |> convert_to_error()
  end

  @doc """
  List all events for a machine.

  ## Examples

      iex> FlyMachines.machine_event_list("my-app", "machine-id")
      {:ok, %Req.Response{status: 200}}
  """
  def machine_event_list(app_name, machine_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(machine_id) do
    req_overrides
    |> from_config()
    |> Req.get(
      url: "/apps/:app/machines/:machine_id/events",
      path_params: [app: app_name, machine_id: machine_id]
    )
    |> convert_to_error()
  end

  @doc """
  List all volumes for an app.

  ## Examples

      iex> FlyMachines.volume_list("my-app")
      {:ok, %Req.Response{status: 200}}
  """
  def volume_list(app_name, req_overrides \\ []) when is_binary(app_name) do
    req_overrides
    |> from_config()
    |> Req.get(url: "/apps/:app/volumes", path_params: [app: app_name])
    |> convert_to_error()
  end

  @doc """
  Create a volume.

  ## Examples

      iex> FlyMachines.volume_create("my-app", %{name: "my-volume", size_gb: 10})
      {:ok, %Req.Response{status: 200}}
  """
  def volume_create(app_name, body, req_overrides \\ [])
      when is_binary(app_name) and is_map(body) do
    req_overrides
    |> from_config()
    |> Req.post(
      url: "/apps/:app/volumes",
      path_params: [app: app_name],
      json: body
    )
    |> convert_to_error()
  end

  @doc """
  Retrieve a volume.

  ## Examples

      iex> FlyMachines.volume_retrieve("my-app", "volume-id")
      {:ok, %Req.Response{status: 200}}
  """
  def volume_retrieve(app_name, volume_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(volume_id) do
    req_overrides
    |> from_config()
    |> Req.get(
      url: "/apps/:app/volumes/:volume_id",
      path_params: [app: app_name, volume_id: volume_id]
    )
    |> convert_to_error()
  end

  @doc """
  Update a volume.

  ## Examples

      iex> FlyMachines.volume_update("my-app", "volume-id", %{snapshot_retention: 1})
      {:ok, %Req.Response{status: 200}}
  """
  def volume_update(app_name, volume_id, body, req_overrides \\ [])
      when is_binary(app_name) and is_binary(volume_id) and is_map(body) do
    req_overrides
    |> from_config()
    |> Req.post(
      url: "/apps/:app/volumes/:volume_id",
      path_params: [app: app_name, volume_id: volume_id],
      json: body
    )
    |> convert_to_error()
  end

  @doc """
  Delete a volume.

  ## Examples

      iex> FlyMachines.volume_delete("my-app", "volume-id")
      {:ok, %Req.Response{status: 200}}
  """
  def volume_delete(app_name, volume_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(volume_id) do
    req_overrides
    |> from_config()
    |> Req.delete(
      url: "/apps/:app/volumes/:volume_id",
      path_params: [app: app_name, volume_id: volume_id]
    )
    |> convert_to_error()
  end

  @doc """
  Extend a volume.

  ## Examples

      iex> FlyMachines.volume_extend("my-app", "volume-id", %{size_gb: 10})
      {:ok, %Req.Response{status: 200}}
  """
  def volume_extend(app_name, volume_id, body, req_overrides \\ [])
      when is_binary(app_name) and is_binary(volume_id) and is_map(body) do
    req_overrides
    |> from_config()
    |> Req.put(
      url: "/apps/:app/volumes/:volume_id/extend",
      path_params: [app: app_name, volume_id: volume_id],
      json: body
    )
    |> convert_to_error()
  end

  @doc """
  List snapshots for a volume.

  ## Examples

        iex> FlyMachines.volume_snapshots_list("my-app", "volume-id")
        {:ok, %Req.Response{status: 200}}
  """
  def volume_snapshots_list(app_name, volume_id, req_overrides \\ [])
      when is_binary(app_name) and is_binary(volume_id) do
    req_overrides
    |> from_config()
    |> Req.get(
      url: "/apps/:app/volumes/:volume_id/snapshot",
      path_params: [app: app_name, volume_id: volume_id]
    )
    |> convert_to_error()
  end

  defp from_config(overrides) do
    :fly_machines
    |> Application.get_env(:default, [])
    |> Req.new()
    |> Req.update(overrides)
  end

  defp convert_to_error({:ok, %Req.Response{status: status} = res}) do
    if status >= 200 and status < 300 do
      {:ok, res}
    else
      {:error, res}
    end
  end

  defp convert_to_error({:error, _} = err), do: err
end
