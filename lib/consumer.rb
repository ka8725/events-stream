require 'events'
require 'set'

keys = [nil, '42', '43', 1,2,3,4,5,6,7,8,9,0,10]

def do_smt(row, fail_key)
  fail OpError if row['key'] == fail_key
  puts "#{row['name']}:#{row['payload']}"
end

OpError = Class.new(StandardError)
conn = Events.connection
conn2 = PG::Connection.open(dbname: 'events')
loop do
  failed = Set.new
  begin
    conn.send_query(<<~SQL)
      select id, name, payload, key from events where processed_at is null
    SQL

    conn.set_single_row_mode
    conn.get_result.stream_each do |row|
      fail_key = keys.sample
      begin
        conn2.transaction do |conn|
          do_smt(row, fail_key)
          conn2.exec_params('update events set processed_at = now() where id = $1', [row['id']])
        end
      rescue OpError
        puts "failed #{fail_key}"
        failed << fail_key
      end
    end
  rescue PG::NoResultError, PG::UnableToSend => e
    puts e.inspect, e.backtrace
  end
  sleep 2
end
