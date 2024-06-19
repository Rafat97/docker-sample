import { createClient } from "@clickhouse/client";

export const clickHouseClient = createClient({
  url: "http://localhost:8123",
  username: "default",
  password: "",
  session_id: "random_session_id",
  max_open_connections: 10,
  request_timeout: 60_000,
  compression: {
    request: true,
    response: false,
  },
  log_level: "TRACE",
  keep_alive: {
    enabled: false,
  },
  clickhouse_settings: {
    date_time_input_format: 'best_effort',
    async_insert: 1,
    wait_for_async_insert: 0,
    wait_for_async_insert: 1,
    async_insert_max_data_size: "1000000",
    async_insert_busy_timeout_ms: 1000,
    // allow_experimental_object_type: 1, // allows JSON type usage
  },
});
