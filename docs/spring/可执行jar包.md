### 制作可执行jar包
引入`spring-boot`打包插件插件
```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
    <!-- 是否可执行 -->
        <executable>true</executable>
    </configuration>
</plugin>
```

### 常见的启动命令
* run
* start
* stop
* stop
* status
* restart

### 配置源的加载顺序
* 命令行参数（Command Line Arguments）：通过在启动应用程序时指定的命令行参数，可以覆盖配置文件中的属性值。命令行参数以--或-开头，后面跟着参数名称和值，例如：--myapp.config.property=value。

* 系统属性（System Properties）：可以通过Java系统属性来配置应用程序的属性值。系统属性可以在启动应用程序时通过-D参数进行设置，例如：java -Dmyapp.config.property=value -jar myapp.jar。

* 环境变量（Environment Variables）：可以使用操作系统的环境变量来配置应用程序的属性值。环境变量的名称需要遵循一定的命名规范，通常使用大写字母和下划线，例如：MYAPP_CONFIG_PROPERTY=value。

* 属性文件（Properties Files）：可以使用.properties或.yml格式的属性文件来配置应用程序的属性值。Spring Boot会自动加载默认的属性文件，例如application.properties或application.yml。可以通过spring.config.name和spring.config.location属性来指定自定义的属性文件名称和路径。

* 配置服务器（Config Servers）：Spring Cloud Config提供了一种集中管理和分发配置的方式，可以从远程配置服务器获取应用程序的属性值。通过使用spring-cloud-config-server模块和相应的配置，可以将配置源集中存储在远程服务器上。

* 配置注解（Configuration Annotations）：可以使用Spring的注解来定义和配置应用程序的属性值，例如@Value、@ConfigurationProperties等注解。这些注解可以将属性值直接注入到Spring的Bean中。

### 命令行变量 &  配置覆盖  
由于优先加载环境变量、命令行变量配置，可一通过启动时指定参数来覆盖配置文件或者默认的参数
* 指定配置文件路径
    * --spring.config.location
* 指定端口 
    * --server.port
* 指定配置文件名称
    * --spring.config.name

### 可执行包运行原理
一般一种文件格式开头都会有固定几个字节来标识（称为魔数），jar包同样存在。
java -jar 在启动时支持查找起始魔数，当头部存在无效内容是会被忽视 。
SpringBoot利用这点在头部插入shell脚本并通过exit 0 结束。
这样执行jar启动时实际是执行jar包头部的shell脚本，再通过java -jar方式执行。

SpringBoot可执行Jar头部脚本如下 
```Shell
#!/bin/bash
#
#    .   ____          _            __ _ _
#   /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
#  ( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
#   \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
#    '  |____| .__|_| |_|_| |_\__, | / / / /
#   =========|_|==============|___/=/_/_/_/
#   :: Spring Boot Startup Script ::
#

### BEGIN INIT INFO
# Provides:          reduck-openapi-integration
# Required-Start:    $remote_fs $syslog $network
# Required-Stop:     $remote_fs $syslog $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: reduck-openapi-integration
# Description:       Demo project for Spring Boot
# chkconfig:         2345 99 01
### END INIT INFO

[[ -n "$DEBUG" ]] && set -x

# Initialize variables that cannot be provided by a .conf file
WORKING_DIR="$(pwd)"
# shellcheck disable=SC2153
[[ -n "$JARFILE" ]] && jarfile="$JARFILE"
[[ -n "$APP_NAME" ]] && identity="$APP_NAME"

# Follow symlinks to find the real jar and detect init.d script
cd "$(dirname "$0")" || exit 1
[[ -z "$jarfile" ]] && jarfile=$(pwd)/$(basename "$0")
while [[ -L "$jarfile" ]]; do
  if [[ "$jarfile" =~ init\.d ]]; then
    init_script=$(basename "$jarfile")
  else
    configfile="${jarfile%.*}.conf"
    # shellcheck source=/dev/null
    [[ -r ${configfile} ]] && source "${configfile}"
  fi
  jarfile=$(readlink "$jarfile")
  cd "$(dirname "$jarfile")" || exit 1
  jarfile=$(pwd)/$(basename "$jarfile")
done
jarfolder="$( (cd "$(dirname "$jarfile")" && pwd -P) )"
cd "$WORKING_DIR" || exit 1

# Inline script specified in build properties


# Source any config file
configfile="$(basename "${jarfile%.*}.conf")"

# Initialize CONF_FOLDER location defaulting to jarfolder
[[ -z "$CONF_FOLDER" ]] && CONF_FOLDER="${jarfolder}"
# shellcheck source=/dev/null
[[ -r "${CONF_FOLDER}/${configfile}" ]] && source "${CONF_FOLDER}/${configfile}"

# ANSI Colors
echoRed() { echo $'\e[0;31m'"$1"$'\e[0m'; }
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }

# Initialize PID/LOG locations if they weren't provided by the config file
[[ -z "$PID_FOLDER" ]] && PID_FOLDER="/var/run"
[[ -z "$LOG_FOLDER" ]] && LOG_FOLDER="/var/log"
! [[ "$PID_FOLDER" == /* ]] && PID_FOLDER="$(dirname "$jarfile")"/"$PID_FOLDER"
! [[ "$LOG_FOLDER" == /* ]] && LOG_FOLDER="$(dirname "$jarfile")"/"$LOG_FOLDER"
! [[ -x "$PID_FOLDER" ]] && echoYellow "PID_FOLDER $PID_FOLDER does not exist. Falling back to /tmp" && PID_FOLDER="/tmp"
! [[ -x "$LOG_FOLDER" ]] && echoYellow "LOG_FOLDER $LOG_FOLDER does not exist. Falling back to /tmp" && LOG_FOLDER="/tmp"

# Set up defaults
[[ -z "$MODE" ]] && MODE="auto" # modes are "auto", "service" or "run"
[[ -z "$USE_START_STOP_DAEMON" ]] && USE_START_STOP_DAEMON="true"

# Create an identity for log/pid files
if [[ -z "$identity" ]]; then
  if [[ -n "$init_script" ]]; then
    identity="${init_script}"
  else
    identity=$(basename "${jarfile%.*}")_${jarfolder//\//}
  fi
fi

# Initialize log file name if not provided by the config file
[[ -z "$LOG_FILENAME" ]] && LOG_FILENAME="${identity}.log"

# Initialize stop wait time if not provided by the config file
[[ -z "$STOP_WAIT_TIME" ]] && STOP_WAIT_TIME="60"

# Utility functions
checkPermissions() {
  touch "$pid_file" &> /dev/null || { echoRed "Operation not permitted (cannot access pid file)"; return 4; }
  touch "$log_file" &> /dev/null || { echoRed "Operation not permitted (cannot access log file)"; return 4; }
}

isRunning() {
  ps -p "$1" &> /dev/null
}

await_file() {
  end=$(date +%s)
  let "end+=10"
  while [[ ! -s "$1" ]]
  do
    now=$(date +%s)
    if [[ $now -ge $end ]]; then
      break
    fi
    sleep 1
  done
}

# Determine the script mode
action="run"
if [[ "$MODE" == "auto" && -n "$init_script" ]] || [[ "$MODE" == "service" ]]; then
  action="$1"
  shift
fi

# Build the pid and log filenames
PID_FOLDER="$PID_FOLDER/${identity}"
pid_file="$PID_FOLDER/${identity}.pid"
log_file="$LOG_FOLDER/$LOG_FILENAME"

# Determine the user to run as if we are root
# shellcheck disable=SC2012
[[ $(id -u) == "0" ]] && run_user=$(ls -ld "$jarfile" | awk '{print $3}')

# Run as user specified in RUN_AS_USER
if [[ -n "$RUN_AS_USER" ]]; then
    if ! [[ "$action" =~ ^(status|run)$ ]]; then
        id -u "$RUN_AS_USER" || {
            echoRed "Cannot run as '$RUN_AS_USER': no such user"
            exit 2
        }
        [[ $(id -u) == 0 ]] || {
            echoRed "Cannot run as '$RUN_AS_USER': current user is not root"
            exit 4
        }
    fi
    run_user="$RUN_AS_USER"
fi

# Issue a warning if the application will run as root
[[ $(id -u ${run_user}) == "0" ]] && { echoYellow "Application is running as root (UID 0). This is considered insecure."; }

# Find Java
if [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]]; then
    javaexe="$JAVA_HOME/bin/java"
elif type -p java > /dev/null 2>&1; then
    javaexe=$(type -p java)
elif [[ -x "/usr/bin/java" ]];  then
    javaexe="/usr/bin/java"
else
    echo "Unable to find Java"
    exit 1
fi

arguments=(-Dsun.misc.URLClassPath.disableJarChecking=true $JAVA_OPTS -jar "$jarfile" $RUN_ARGS "$@")

# Action functions
start() {
  if [[ -f "$pid_file" ]]; then
    pid=$(cat "$pid_file")
    isRunning "$pid" && { echoYellow "Already running [$pid]"; return 0; }
  fi
  do_start "$@"
}

do_start() {
  working_dir=$(dirname "$jarfile")
  pushd "$working_dir" > /dev/null
  if [[ ! -e "$PID_FOLDER" ]]; then
    mkdir -p "$PID_FOLDER" &> /dev/null
    if [[ -n "$run_user" ]]; then
      chown "$run_user" "$PID_FOLDER"
    fi
  fi
  if [[ ! -e "$log_file" ]]; then
    touch "$log_file" &> /dev/null
    if [[ -n "$run_user" ]]; then
      chown "$run_user" "$log_file"
    fi
  fi
  if [[ -n "$run_user" ]]; then
    checkPermissions || return $?
    if [ $USE_START_STOP_DAEMON = true ] && type start-stop-daemon > /dev/null 2>&1; then
      start-stop-daemon --start --quiet \
        --chuid "$run_user" \
        --name "$identity" \
        --make-pidfile --pidfile "$pid_file" \
        --background --no-close \
        --startas "$javaexe" \
        --chdir "$working_dir" \
        -- "${arguments[@]}" \
        >> "$log_file" 2>&1
      await_file "$pid_file"
    else
      su -s /bin/sh -c "$javaexe $(printf "\"%s\" " "${arguments[@]}") >> \"$log_file\" 2>&1 & echo \$!" "$run_user" > "$pid_file"
    fi
    pid=$(cat "$pid_file")
  else
    checkPermissions || return $?
    "$javaexe" "${arguments[@]}" >> "$log_file" 2>&1 &
    pid=$!
    disown $pid
    echo "$pid" > "$pid_file"
  fi
  [[ -z $pid ]] && { echoRed "Failed to start"; return 1; }
  echoGreen "Started [$pid]"
}

stop() {
  working_dir=$(dirname "$jarfile")
  pushd "$working_dir" > /dev/null
  [[ -f $pid_file ]] || { echoYellow "Not running (pidfile not found)"; return 0; }
  pid=$(cat "$pid_file")
  isRunning "$pid" || { echoYellow "Not running (process ${pid}). Removing stale pid file."; rm -f "$pid_file"; return 0; }
  do_stop "$pid" "$pid_file"
}

do_stop() {
  kill "$1" &> /dev/null || { echoRed "Unable to kill process $1"; return 1; }
  for ((i = 1; i <= STOP_WAIT_TIME; i++)); do
    isRunning "$1" || { echoGreen "Stopped [$1]"; rm -f "$2"; return 0; }
    [[ $i -eq STOP_WAIT_TIME/2 ]] && kill "$1" &> /dev/null
    sleep 1
  done
  echoRed "Unable to kill process $1";
  return 1;
}

force_stop() {
  [[ -f $pid_file ]] || { echoYellow "Not running (pidfile not found)"; return 0; }
  pid=$(cat "$pid_file")
  isRunning "$pid" || { echoYellow "Not running (process ${pid}). Removing stale pid file."; rm -f "$pid_file"; return 0; }
  do_force_stop "$pid" "$pid_file"
}

do_force_stop() {
  kill -9 "$1" &> /dev/null || { echoRed "Unable to kill process $1"; return 1; }
  for ((i = 1; i <= STOP_WAIT_TIME; i++)); do
    isRunning "$1" || { echoGreen "Stopped [$1]"; rm -f "$2"; return 0; }
    [[ $i -eq STOP_WAIT_TIME/2 ]] && kill -9 "$1" &> /dev/null
    sleep 1
  done
  echoRed "Unable to kill process $1";
  return 1;
}

restart() {
  stop && start
}

force_reload() {
  working_dir=$(dirname "$jarfile")
  pushd "$working_dir" > /dev/null
  [[ -f $pid_file ]] || { echoRed "Not running (pidfile not found)"; return 7; }
  pid=$(cat "$pid_file")
  rm -f "$pid_file"
  isRunning "$pid" || { echoRed "Not running (process ${pid} not found)"; return 7; }
  do_stop "$pid" "$pid_file"
  do_start
}

status() {
  working_dir=$(dirname "$jarfile")
  pushd "$working_dir" > /dev/null
  [[ -f "$pid_file" ]] || { echoRed "Not running"; return 3; }
  pid=$(cat "$pid_file")
  isRunning "$pid" || { echoRed "Not running (process ${pid} not found)"; return 1; }
  echoGreen "Running [$pid]"
  return 0
}

run() {
  pushd "$(dirname "$jarfile")" > /dev/null
  "$javaexe" "${arguments[@]}"
  result=$?
  popd > /dev/null
  return "$result"
}

# Call the appropriate action function
case "$action" in
start)
  start "$@"; exit $?;;
stop)
  stop "$@"; exit $?;;
force-stop)
  force_stop "$@"; exit $?;;
restart)
  restart "$@"; exit $?;;
force-reload)
  force_reload "$@"; exit $?;;
status)
  status "$@"; exit $?;;
run)
  run "$@"; exit $?;;
*)
  echo "Usage: $0 {start|stop|force-stop|restart|force-reload|status|run}"; exit 1;
esac

exit 0
```