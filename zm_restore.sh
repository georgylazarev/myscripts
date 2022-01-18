#!/bin/bash

period=$1; # Задается период восстановления - год, месяц или день
mbox=$2; # Электронная почта сотрудника

restoreYear=$3;
restoreMonth=$4;
restoreDay=$5;

zmbox="/opt/zimbra/bin/zmmailbox";

case $period in
  [Yy] ) backupFolder="/opt/zimbra/backup/backups/$mbox/$restoreYear";;
  [Mm] ) backupFolder="/opt/zimbra/backup/backups/$mbox/$restoreYear/$restoreMonth";;
  [Dd] ) backupFolder="/opt/zimbra/backup/backups/$mbox/$restoreYear/$restoreMonth/$restoreDay";;
  * ) echo "Введите период восстановления Y - год, M - месяц, D - день";;
esac

# Скрипт рекурсивно просматривает указанные директории
for file in `find $backupFolder -type f -name "*.tgz"`
do
  $zmbox -z -m $mbox -t 0 postRestURL "//?fmt=tgz&resolve=skip" $file;
done
