defmodule LoggerWebhookBackendTest do
  use ExUnit.Case
  require Logger

  doctest LoggerWebhookBackend

  @moduletag :capture_log

  setup do
    bypass = Bypass.open()
    webhook_url = "http://localhost:#{bypass.port}/webhook"

    config = [
      level: :info,
      webhook_url: webhook_url
    ]

    LoggerBackends.add(LoggerWebhookBackend)
    LoggerBackends.configure(LoggerWebhookBackend, config)

    on_exit(fn ->
      LoggerBackends.remove(LoggerWebhookBackend)
    end)

    {:ok, bypass: bypass, webhook_url: webhook_url}
  end

  describe "initialization and configuration" do
    test "initialize with options", %{webhook_url: webhook_url} do
      opts = [webhook_url: webhook_url, level: :error]
      {:ok, state} = LoggerWebhookBackend.init({LoggerWebhookBackend, :test_backend})
      {:ok, :ok, new_state} = LoggerWebhookBackend.handle_call({:configure, opts}, state)

      assert new_state.name == :test_backend
      assert new_state.webhook_url == webhook_url
      assert new_state.level == :error
    end
  end
end
