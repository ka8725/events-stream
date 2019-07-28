require 'events'
require 'set'

keys = [nil, '42', '43', 1,2,3,4,5,6,7,8,9,0,10]

def do_smt(row)
  puts "#{row['name']}:#{row['payload']}"
end

OpError = Class.new(StandardError)
conn = Events.connection
loop do
  failed = Set.new
  fail_key = keys.sample
  begin
    conn.send_query(<<~SQL)
      select id, name, payload, key from events where processed_at is null
    SQL

    conn.set_single_row_mode

    loop do
      res = conn.get_result or break
      res.each do |row|
        next if row['key'] && failed.include?(row['key'])

        conn.transaction do |conn|
          do_smt(row) and (fail(OpError) if res['key'] == fail_key)
          conn.exec_params('update events set processed_at = now() where id = $1', [row['id']])
        rescue OpError
          puts "failed #{fail_key}"
          failed << fail_key
        end
      end
    end
  rescue PG::NoResultError, PG::UnableToSend => e
    puts e
  end
  sleep 2
end
