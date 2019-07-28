- `createdb events`
- `psql -f migration.sql`

Start producer:
`ruby -I lib lib/producer.rb`

Start consumer:
`ruby -I lib lib/consumer.rb`
