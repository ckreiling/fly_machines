import Config

if config_env() != :docs do
  config :fly_machines,
    default: [
      base_url: "https://api.machines.dev/v1",
      auth: {:bearer, System.fetch_env!("FLY_API_TOKEN")}
    ]
end

if config_env() == :test do
  test_app_prefix = System.get_env("FLY_TEST_APP_PREFIX")

  if is_nil(test_app_prefix) do
    raise """
    Missing FLY_TEST_APP_PREFIX environment variable.
    This is used to namespace test apps created by the test suite.
    """
  end

  test_org = System.get_env("FLY_TEST_ORG")

  if is_nil(test_org) do
    raise """
    Missing FLY_TEST_ORG environment variable.
    This is used for apps being tested.
    """
  end

  test_region = System.get_env("FLY_TEST_REGION")

  if is_nil(test_region) do
    raise """
    Missing FLY_TEST_REGION environment variable.
    This is used as the region for machines and volumes created in tests.
    """
  end

  config :fly_machines,
    test_app_prefix: test_app_prefix,
    test_org: test_org,
    test_region: test_region
end
