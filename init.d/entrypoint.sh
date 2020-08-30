#!/bin/bash +e
# catch signals as PID 1 in a container

# SIGNAL-handler
term_handler() {
   echo "terminating node-red ..."
   /etc/init.d/nodered.sh stop
  
  exit 143; # 128 + 15 -- SIGTERM
}

# on callback, stop all started processes in term_handler
trap 'kill ${!}; term_handler' SIGINT SIGKILL SIGTERM SIGQUIT SIGTSTP SIGSTOP SIGHUP

cat << EOF > /usr/bin/cmd_restart
#!/bin/sh
echo 1 >/proc/sys/kernel/sysrq && echo s > /proc/sysrq-trigger && sleep 10 && echo b > /proc/sysrq-trigger
EOF
sudo chmod 755 /usr/bin/cmd_restart
cat << EOF > /usr/bin/cmd_shutdown
#!/bin/sh
echo 1 >/proc/sys/kernel/sysrq && echo o > /proc/sysrq-trigger && sleep 10 && echo b > /proc/sysrq-trigger
EOF
sudo chmod 755 /usr/bin/cmd_shutdown

# run applications in the background
/etc/init.d/nodered.sh start & 

# wait forever not to exit the container
while true
do
  tail -f /dev/null & wait ${!}
done

exit 0
