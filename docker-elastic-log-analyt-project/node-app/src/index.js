const { processLogs } = require("./insertLogs");

const logFilePath = "./logs/logs.json";

processLogs(logFilePath)
  .then(() => {
    console.log("All logs have been processed");
  })
  .catch((err) => {
    console.error("Error processing logs:", err);
  });
