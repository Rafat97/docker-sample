const express = require("express");
const bodyParser = require("body-parser");
import { clickHouseClient } from "./clickhouse.mjs";

const app = express();
const port = process.env.PORT || 3000;

app.use(bodyParser.json());

app.post("/track", async (req, res) => {
  const { event_name, user_id, event_properties } = req.body;

  try {
    const query = `
      INSERT INTO events (event_date, event_name, user_id, event_properties)
      VALUES (now(), '${event_name}', ${user_id}, '${JSON.stringify(
      event_properties
    )}')
    `;
    await clickHouseClient.query(query).toPromise();
    res.status(200).send("Event tracked successfully");
  } catch (error) {
    console.error("Error tracking event:", error);
    res.status(500).send("Error tracking event");
  }
});

app.get("/query", async (req, res) => {
  try {
    const result = await clickHouseClient
      .query("SELECT * FROM events LIMIT 10")
      .toPromise();
    res.json(result);
  } catch (error) {
    console.error("Error querying events:", error);
    res.status(500).send("Error querying events");
  }
});

const createTable = async (req, res) => {
  // DROP TABLE events;
  await clickHouseClient.command({
    query: `


      CREATE TABLE IF NOT EXISTS events (
        event_date DateTime DEFAULT now(),
        event_name String,
        distinct_id String, 
        user_id UInt64,
        event_properties String,
      ) ENGINE = MergeTree()
      PARTITION BY toYYYYMMDD(event_date)
      ORDER BY (event_date, event_name, user_id, distinct_id);


    `,
  });
};

app.listen(port, async () => {
  await createTable();

  let rows = await clickHouseClient.query({
    query: "SELECT 1",
    format: "JSONEachRow",
  });
  console.log("Result: ", await rows.json());

  rows = await clickHouseClient.query({
    query: "SELECT * FROM events",
    format: "JSONEachRow",
  });
  console.log("Result events: ", await rows.json());

  console.log(`Server is running on http://localhost:${port}`);
});
