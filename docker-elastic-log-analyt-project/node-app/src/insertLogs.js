const fs = require('fs');
const readline = require('readline');
const { Client } = require('@elastic/elasticsearch');

const client = new Client({ node: 'http://localhost:9200', auth: { username: 'elastic', password: 'your_password' } });

async function insertLog(index, log) {
  try {
    const response = await client.index({
      index: index,
      body: log
    });
    console.log('Log inserted:', response.body);
  } catch (error) {
    console.error('Error inserting log:', error);
  }
}

async function processLogs(filePath) {
  const fileStream = fs.createReadStream(filePath);
  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  for await (const line of rl) {
    const date = new Date();
    const indexName = `demo-logs-${date.getUTCFullYear()}.${String(date.getUTCMonth() + 1).padStart(2, '0')}.${String(date.getUTCDate()).padStart(2, '0')}.${String(date.getUTCHours()).padStart(2, '0')}`; // e.g., logs-2024.06.13.14
  
    const logEntry = JSON.parse(line);
    console.log(logEntry);
    await insertLog(indexName, logEntry);
  }
}

module.exports = { processLogs };