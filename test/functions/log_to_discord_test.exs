defmodule LoggerWebhookBackendTest.Functions.LogToDiscord do
  require Logger
  use ExUnit.Case

  setup do
    webhook_url = System.get_env("DISCORD_TEST_WEBHOOK_URL")

    unless webhook_url do
      flunk("DISCORD_TEST_WEBHOOK_URL not provided")
    end

    config = [
      level: :error,
      webhook_url: webhook_url
    ]

    LoggerBackends.add({LoggerWebhookBackend, :webhook_logger})
    LoggerBackends.configure({LoggerWebhookBackend, :webhook_logger}, config)

    on_exit(fn ->
      LoggerBackends.remove({LoggerWebhookBackend, :webhook_logger})
    end)
  end

  # test "basic message to mocked Discord webhook" do
  #   webhook_url = "http://localhost:4000/webhook"
  #   log_level = :info
  #   message = "Hello, world!"
  #   timestamp = DateTime.utc_now()
  #   metadata = %{application: "test_app"}

  #   # TODO: Mock the HTTP request to the Discord webhook using Bypass
  # end

  test "send message to real webhook" do
    Logger.error("Sending log to Discord webhook")
  end
end
