defmodule LoggerWebhookBackendTest.Functions.LogToDiscord do
  use ExUnit.Case

  test "basic message to mocked Discord webhook" do
    webhook_url = "http://localhost:4000/webhook"
    log_level = :info
    message = "Hello, world!"
    timestamp = DateTime.utc_now()
    metadata = %{application: "test_app"}

    # TODO: Mock the HTTP request to the Discord webhook using Bypass
  end
end
