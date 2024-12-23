defmodule LoggerWebhookBackend do
  @moduledoc """
  `logger_webhook_backend` is a custom logger backend for `Logger` that sends logs to a specified webhook URL. Presently, it only supports sending logs to Discord webhooks.

  ## Configuration

  `logger_webhook_backend` can be configured in your `config.exs` file. The following configuration options are available:
  ```elixir
    config :logger,
      backends: [{MyAppModule, :webhook_logger}]

    config :logger, :webhook_logger, level: :error
  ```

  Environment variables can be set in your `runtime.exs` file, like so:
  ```elixir
    config :logger, :webhook_logger,
      webhook_url: System.get_env("WEBHOOK_URL")
  ```
  """

  require Logger

  @behaviour :gen_event

  def init({__MODULE__, name}) do
    {:ok, configure(name, [])}
  end

  def handle_call({:configure, opts}, %{name: name} = state) do
    {:ok, :ok, configure(name, opts, state)}
  end

  def handle_event({_level, gl, {Logger, _, _, _}}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{} = state) do
    if is_level_okay(level, state.level) do
      log_to_discord(state.webhook_url, level, msg, ts, md)
    end

    {:ok, state}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  defp is_level_okay(lvl, min_level) do
    is_nil(min_level) or Logger.compare_levels(lvl, min_level) != :lt
  end

  @doc """
  Send a log message to a Discord webhook URL.
  """
  @spec log_to_discord(
          webhook_url :: String.t(),
          log_level ::
            :debug | :info | :notice | :warning | :error | :critical | :alert | :emergency,
          message :: iodata,
          timestamp :: DateTime.t(),
          metadata :: map
        ) :: :ok | {:error, term}
  def log_to_discord(webhook_url, log_level, message, timestamp, metadata) do
    formatted_msg = format_message(log_level, message, timestamp, metadata)
    body = %{content: formatted_msg} |> Jason.encode!()
    headers = [{~c"Content-Type", ~c"application/json"}]

    :httpc.request(
      :post,
      {webhook_url, headers, ~c"application/json", body},
      [],
      []
    )
    |> case do
      {:ok, {{~c"HTTP/1.1", status, _}, _headers, _body}} when status in 200..299 ->
        :ok

      {:ok, {{~c"HTTP/1.1", status, _}, _headers, response_body}} ->
        Logger.error(
          "Failed to send log to Discord: Status #{status}, Body: #{inspect(response_body)}"
        )

      {:error, reason} ->
        Logger.error("Error sending log to Discord: #{inspect(reason)}")
    end
  end

  @doc """
  Format a log message for markdown enabled webhooks. Used internally by `log_to_discord/5`.
  """
  @spec format_message(
          log_level ::
            :debug | :info | :notice | :warning | :error | :critical | :alert | :emergency,
          message :: iodata,
          timestamp :: DateTime.t(),
          metadata :: map
        ) :: iodata
  def format_message(log_level, message, _timestamp, metadata) do
    timestamp = DateTime.utc_now()
    source = metadata[:application]
    message = IO.iodata_to_binary(message) |> String.slice(0..1900)

    "[#{timestamp}] [#{source}] [#{log_level}] `#{message}`"
  end

  defp configure(name, opts) do
    state = %{name: name, format: nil, level: nil, metadata: nil, metadata_filter: nil}
    configure(name, opts, state)
  end

  defp configure(name, opts, state) do
    env = Application.get_env(:logger, name, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, name, opts)

    new_state = %{
      webhook_url: Keyword.get(opts, :webhook_url, nil),
      level: Keyword.get(opts, :level)
    }

    Map.merge(state, new_state)
  end
end
