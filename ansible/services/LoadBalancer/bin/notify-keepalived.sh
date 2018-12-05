#!/bin/bash
TYPE=$1
NAME=$2
STATE=$3
kpicnfg(){
  kpiuncnfg
  test -w /etc/crontab && echo "@hourly root /var/iap/bin/AMXKPI00.sh" >> /etc/crontab && grep -q AMXKPI00 /etc/crontab
  return $?
}
kpiuncnfg(){
  local _ret=1
  test -w /etc/crontab && sed -i '/AMXKPI00/d' /etc/crontab && _ret=`grep -c AMXKPI00 /etc/crontab`
  return $_ret
}
_ret=1
case "$STATE" in
  "MASTER")
    kpicnfg
    _ret=$?
    ;;
  "BACKUP")
    kpiuncnfg
    _ret=$?
    ;;
  "FAULT")
    kpiuncnfg
    _ret=$?
    ;;
  *)
    ;;
esac
exit $_ret
