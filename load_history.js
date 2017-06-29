const _ = require('lodash');
const pg = require('pg');

const connectionString = 'postgres://some_id:some_password@localhost:5433/dynamodb';

const client = new pg.Client(connectionString);
client.connect();

const query = client.query('SELECT * FROM km_result', (err, res) => {
  if (err) {
    console.log(err.stack);
  } else {
    console.log(res.rows[0]);
  }
});
// query.on('end', () => { client.end(); });

const fs = require('fs');

const obj = fs.readFileSync('/home/ubuntu/some/where/location.json', 'utf8');
// console.log(String(obj));

const json = JSON.parse(String(obj));
const jsonFiltered = _.filter(json, (value) => {
  return value.timestampMs > 1497884400000; // 2017年6月20日 00:00:00
});

// console.log(jsonFiltered);
