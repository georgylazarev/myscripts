#!/bin/bash

zmbox=/opt/zimbra/bin/zmmailbox
zmprov=/opt/zimbra/bin/zmprov
backupdir=/opt/zimbra/backup/backups
cur_year=$(date +%Y)
cur_month=$(date +%m)
cur_day=$(date +%d)
today=$(date +%m/%d/%y)
day_before_yesterday=$(date +%m/%d/%y -d "2 days ago")

echo "$(date +%T): Начало бэкапирования" > /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log
echo "" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log

echo "$(date +%T): Постоение списка активных аккаунтов" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log
sudo -u zimbra $zmprov -l sa "(zimbraAccountStatus=active)" > /opt/zimbra/backup/active_accounts/$(date +%Y-%m-%d)_accounts && echo "$(date +%T): Список построен" >> ./logs/$(date +%Y-%m-%d)_backup_log
echo "" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log

echo "$(date +%T): Начало обработки ящиков" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log
echo "" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log

cat /opt/zimbra/backup/active_accounts/$(date +%Y-%m-%d)_accounts | while read mbox
do
        echo "$(date +%T): Начало обработки ящика $mbox" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log
#Проверка и создание директорий
        if ! [ -d $backupdir/$mbox/ ]; then
                echo "$(date +%T): Директория $mbox отсутствует" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log
                mkdir $backupdir/$mbox && echo "$(date +%T): Директория $mbox создана" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log
        fi
        if ! [ -d $backupdir/$mbox/$cur_year ]; then
                echo "$(date +%T): Директория $mbox/$cur_year отсутствует" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log
                mkdir $backupdir/$mbox/$cur_year && echo "$(date +%T): Директория $mbox/$cur_year создана" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log
        fi
        if ! [ -d $backupdir/$mbox/$cur_year/$cur_month ]; then
                echo "$(date +%T): Директория $mbox/$cur_year/$cur_month отсутствует" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log
                mkdir $backupdir/$mbox/$cur_year/$cur_month && echo "$(date +%T): Директория $mbox/$cur_year/$cur_month создана" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log
        fi
        if ! [ -d $backupdir/$mbox/$cur_year/$cur_month/$cur_day ]; then
                echo "$(date +%T): Директория $mbox/$cur_year/$cur_month/$cur_day отсутствует" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log
                mkdir $backupdir/$mbox/$cur_year/$cur_month/$cur_day && echo "$(date +%T): Директория $mbox/$cur_year/$cur_month/$cur_day создана" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log
        fi
#       chown -R zimbra:zimbra $backupdir/$mbox
        userdir=$(echo $mbox | sed 's/@/\@/')
        sudo -u zimbra $zmbox -z -m $mbox getRestURL "/?fmt=tgz&query=after:$(date  +%m/%d/%y -d '2 days ago') and before:$(date  +%m/%d/%y)" > $backupdir/$userdir/$cur_year/$cur_month/$cur_day/$mbox-$(date +%m-%d-%y).tgz && echo "$(date +%T): Бэкап писем $mbox готов" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log 
        echo "" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log

done
echo "$(date +%T): Окончание обработки ящиков" >> /opt/zimbra/backup/logs/$(date +%Y-%m-%d)_backup_log
