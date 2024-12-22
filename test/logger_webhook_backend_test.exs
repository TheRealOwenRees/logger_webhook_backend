defmodule LoggerWebhookBackendTest do
  use ExUnit.Case
  doctest LoggerWebhookBackend

  test "greets the world" do
    assert LoggerWebhookBackend.hello() == :world
  end
end
