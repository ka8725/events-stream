ruby -I lib lib/consumer.rb &
TASK_PID=$!
echo $TASK_PID
sleep 10
kill $TASK_PID
