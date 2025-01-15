defmodule LoggerWebhookBackendTest.Functions.LogToDiscord do
  require Logger
  use ExUnit.Case

  setup do
    bypass = Bypass.open()

    webhook_url = System.get_env("DISCORD_TEST_WEBHOOK_URL")
    mock_webhook_url = "http://localhost:#{bypass.port}"

    unless webhook_url do
      flunk("DISCORD_TEST_WEBHOOK_URL not provided")
    end

    webhooks_urls = %{
      real: webhook_url,
      mock: mock_webhook_url
    }

    {:ok, bypass: bypass, webhook_urls: webhooks_urls}
  end

  describe "mocked webhook tests" do
    setup %{webhook_urls: webhook_urls} do
      config = [
        level: :error,
        webhook_url: webhook_urls.mock
      ]

      LoggerBackends.add({LoggerWebhookBackend, :webhook_logger})
      LoggerBackends.configure({LoggerWebhookBackend, :webhook_logger}, config)

      on_exit(fn ->
        LoggerBackends.remove({LoggerWebhookBackend, :webhook_logger})
      end)

      :ok
    end

    test "sends a message to the mocked Discord webhook", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        payload = Jason.decode!(body)

        # Verify the payload format
        assert is_map(payload)
        assert Map.has_key?(payload, "content")
        assert payload["content"] =~ "[error]"
        assert payload["content"] =~ "Test mock webhook message"

        Plug.Conn.resp(conn, 200, "")
      end)

      Logger.error("Test mock webhook message",
        metadata1: "test_metadata_1",
        metadata2: "test_metadata_2"
      )
    end
  end

  # manual testing required due to the nature of the test. Check the Discord channel for the message.
  describe "real webhook tests" do
    setup %{webhook_urls: webhook_urls} do
      config = [
        level: :error,
        webhook_url: webhook_urls.real
      ]

      LoggerBackends.add({LoggerWebhookBackend, :webhook_logger})
      LoggerBackends.configure({LoggerWebhookBackend, :webhook_logger}, config)

      on_exit(fn ->
        LoggerBackends.remove({LoggerWebhookBackend, :webhook_logger})
      end)
    end

    @tag :integration
    test "send message to real webhook" do
      Logger.error("Sending log to actual Discord webhook",
        metadata1: "test_metadata_1",
        metadata2: "test_metadata_2"
      )
    end
  end
end
