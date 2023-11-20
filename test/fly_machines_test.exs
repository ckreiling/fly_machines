defmodule FlyMachinesTest do
  use ExUnit.Case

  import FlyMachines

  alias FlyMachines.Response

  setup_all do
    vars = setup_vars(true)
    IO.puts("Created app '#{vars[:app]}' in org '#{vars[:org]}'")

    on_exit(fn ->
      {:ok, _} = app_delete(vars[:app])
      IO.puts("Deleted app '#{vars[:app]}' in org '#{vars[:org]}'")
    end)

    vars
  end

  describe "Fly Apps" do
    @describetag integration: :apps

    setup do
      setup_vars()
    end

    test "can be created, read, and deleted", %{app: app, org: org} do
      assert {:ok, %Response{status: 201, body: created}} =
               app_create(%{org_slug: org, app_name: app})

      assert {:ok, %Response{status: 200, body: retrieved}} = app_retrieve(app)

      assert created["app_name"] == retrieved["app_name"]

      assert {:ok, %Response{status: 202}} = app_delete(app)
    end
  end

  describe "Fly Machines" do
    @describetag integration: :machines

    test "can be created and subsequently read", %{app: app, region: region} do
      assert {:ok, %Response{status: 200, body: created}} =
               machine_create(app, %{region: region, config: %{image: "flyio/hellofly:latest"}})

      assert {:ok, %Response{status: 200, body: retrieved}} =
               machine_retrieve(app, created["id"])

      assert created["id"] == retrieved["id"]
    end

    test "can be created and subsequently updated", %{app: app, region: region} do
      assert {:ok, %Response{status: 200, body: created}} =
               machine_create(app, %{region: region, config: %{image: "flyio/hellofly:latest"}})

      assert {:ok, %Response{status: 200, body: updated}} =
               machine_update(app, created["id"], %{
                 region: region,
                 config: %{image: "nginx:latest"}
               })

      assert get_in(created, ~w[config image]) == "flyio/hellofly:latest"
      assert get_in(updated, ~w[config image]) == "nginx:latest"
    end

    test "can be stopped and awaited, and finally destroyed", %{app: app, region: region} do
      assert {:ok, %Response{status: 200, body: created}} =
               machine_create(app, %{region: region, config: %{image: "flyio/hellofly:latest"}})

      # the API errors out when stopping a machine that is not yet started
      assert {:ok, %Response{status: 200}} =
               machine_wait(app, created["id"], %{state: "started", timeout: 10})

      assert {:ok, %Response{status: 200}} = machine_stop(app, created["id"])

      # the API requires that stopping a machine be done with the instance_id
      assert {:ok, %Response{status: 200}} =
               machine_wait(app, created["id"], %{
                 state: "stopped",
                 timeout: 10,
                 instance_id: created["instance_id"]
               })

      assert {:ok, %Response{status: 200}} =
               machine_delete(app, created["id"])
    end

    test "can be cordoned and then uncordoned", %{app: app, region: region} do
      assert {:ok, %Response{status: 200, body: created}} =
               machine_create(app, %{region: region, config: %{image: "flyio/hellofly:latest"}})

      assert {:ok, %Response{status: 200}} =
               machine_wait(app, created["id"], %{state: "started", timeout: 10})

      assert {:ok, %Response{status: 200}} = machine_cordon(app, created["id"])

      assert {:ok, %Response{status: 200, body: %{"ok" => true}}} =
               machine_uncordon(app, created["id"])
    end
  end

  describe "Fly Volumes" do
    @describetag integration: :volumes

    test "can be created and subsequently read", %{app: app, region: region} do
      assert {:ok, %Response{status: 200, body: created}} =
               volume_create(app, %{
                 name: "test_volume",
                 size_gb: 1,
                 region: region
               })

      assert {:ok, %Response{status: 200, body: retrieved}} =
               volume_retrieve(app, created["id"])

      assert created["id"] == retrieved["id"]
    end

    test "can be created and subsequently extended", %{app: app, region: region} do
      assert {:ok, %Response{status: 200, body: created}} =
               volume_create(app, %{name: "test_volume", size_gb: 1, region: region})

      assert {:ok, %Response{status: 200}} =
               volume_extend(app, created["id"], %{size_gb: 2})
    end

    test "can be destroyed", %{app: app, region: region} do
      assert {:ok, %Response{status: 200, body: created}} =
               volume_create(app, %{name: "test_volume", size_gb: 1, region: region})

      assert {:ok, %Response{status: 200}} = volume_delete(app, created["id"])
    end
  end

  defp setup_vars(create_app \\ false) do
    org = Application.get_env(:fly_machines, :test_org)

    random = random_string(6)
    app_prefix = Application.get_env(:fly_machines, :test_app_prefix)
    app = app_prefix <> random

    if create_app do
      {:ok, _} = app_create(%{org_slug: org, app_name: app})
    end

    region = Application.get_env(:fly_machines, :test_region)
    [app: app, org: org, region: region]
  end

  @random_chars Enum.concat([?a..?z, ?0..?9])

  defp random_string(length) do
    Stream.repeatedly(fn -> Enum.random(@random_chars) end)
    |> Enum.take(length)
    |> List.to_string()
  end
end
