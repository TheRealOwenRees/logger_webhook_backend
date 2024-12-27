# Logger Webhook Backend

A Logger backend that sends logs to a webhook. Currently only tested with Discord.

## Installation

The package can be installed by adding `logger_webhook_backend` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logger_webhook_backend, "~> 0.0.2"}
  ]
end
```

## Configuration

`LoggerWebhookBackend` can be configured in your `config.exs` file:

```elixir
config :logger,
  backends: [{LoggerWebhookBackend, :webhook_logger}]

config :logger, :webhook_logger, level: :error
```

Environment variables can be set in your `runtime.exs` file:

```elixir
config :logger, :webhook_logger,
  webhook_url: System.get_env("WEBHOOK_URL")
```
