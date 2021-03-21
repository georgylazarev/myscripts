#!/bin/bash
root_date=$(date +%Y-%m-%d -d "$1") # Дата создания бэкапа. !!!Сам бэкап берется за день до заданной даты!!!

zmbox=/opt/zimbra/bin/zmmailbox
zmprov=/opt/zimbra/bin/zmprov
backupdir=/opt/zimbra/backup

backup_log="$backupdir/logs/${root_date}_backup_log" # Файл логов
active_accounts="$backupdir/active_accounts/${root_date}_accounts" # Файл активных на текущий день аккаунтов

cur_year=$(echo $root_date | cut -d'-' -f 1) # Год для создания директории
cur_month=$(echo $root_date | cut -d'-' -f 2) # Месяц для создания директории
cur_day=$(echo $root_date | cut -d'-' -f 3) # День для создания директории

after_date=$(date +%D -d "$root_date 2 days ago") # Бэкап после этой даты
before_date=$(date +%D -d "$root_date") # Бэкап до этой даты

echo "$(date +%T): Начало бэкапирования" > $backup_log
echo "" >> $backup_log

echo "$(date +%T): Постоение списка активных аккаунтов" >> $backup_log
sudo -u zimbra $zmprov -l sa "(zimbraAccountStatus=active)" > $active_accounts # Аккаунты на текущий день
&& echo "$(date +%T): Список построен" >> $backup_log
echo "" >> $backup_log

echo "$(date +%T): Начало обработки ящиков" >> $backup_log
echo "" >> $backup_log

cat $active_accounts | while read mbox
do
  echo "$(date +%T): Начало обработки ящика $mbox" >> $backup_log

  #Проверка и создание директорий
  if ! [ -d $backupdir/backups/$mbox/ ]; then
    echo "$(date +%T): Директория $mbox отсутствует" >> $backup_log
    mkdir $backupdir/backups/$mbox
    && echo "$(date +%T): Директория $mbox создана" >> $backup_log
  fi

  if ! [ -d $backupdir/backups/$mbox/$cur_year ]; then
    echo "$(date +%T): Директория $mbox/$cur_year отсутствует" >> $backup_log
    mkdir $backupdir/backups/$mbox/$cur_year
    && echo "$(date +%T): Директория $mbox/$cur_year создана" >> $backup_log
  fi

  if ! [ -d $backupdir/backups/$mbox/$cur_year/$cur_month ]; then
    echo "$(date +%T): Директория $mbox/$cur_year/$cur_month отсутствует" >> $backup_log
    mkdir $backupdir/backups/$mbox/$cur_year/$cur_month
    && echo "$(date +%T): Директория $mbox/$cur_year/$cur_month создана" >> $backup_log
  fi

  if ! [ -d $backupdir/backups/$mbox/$cur_year/$cur_month/$cur_day ]; then
    echo "$(date +%T): Директория $mbox/$cur_year/$cur_month/$cur_day отсутствует" >> $backup_log
    mkdir $backupdir/backups/$mbox/$cur_year/$cur_month/$cur_day
    && echo "$(date +%T): Директория $mbox/$cur_year/$cur_month/$cur_day создана" >> $backup_log
  fi

  userdir="$backupdir/backups/$(echo $mbox | sed 's/@/\@/')/$cur_year/$cur_month/$cur_day"
  sudo -u zimbra $zmbox -z -m $mbox getRestURL "/?fmt=tgz&query=after:$after_date and before:$before_date" > $userdir/$mbox-$root_date.tgz
  && echo "$(date +%T): Бэкап писем $mbox готов" >> $backup_log
  echo "" >> $backup_log
done
echo "$(date +%T): Окончание обработки ящиков" >> $backup_log
