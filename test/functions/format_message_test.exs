defmodule LoggerWebhookBackendTest.Functions.FormatMessage do
  use ExUnit.Case

  test "basic message format" do
    log_level = :info
    message = "Hello, world!"
    metadata = %{application: "test_app"}
    timestamp = DateTime.utc_now()

    formatted_msg =
      LoggerWebhookBackend.format_message(log_level, message, timestamp, metadata)

    # Assert the timestamp is within an acceptable delta
    [_, timestamp_part] = Regex.run(~r/\[(.*?)\]/, formatted_msg)
    {:ok, parsed_timestamp, _} = DateTime.from_iso8601(timestamp_part)
    assert_in_delta DateTime.to_unix(timestamp), DateTime.to_unix(parsed_timestamp), 2

    # Assert the formatted message is within the 2000 character limit
    assert byte_size(formatted_msg) <= 2000

    # Assert the formatted message is correct
    assert formatted_msg == "[#{parsed_timestamp}] [test_app] [info] `Hello, world!`"
  end
end
