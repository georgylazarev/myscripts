#!/bin/bash
userid=$(sudo -u zimbra /opt/zimbra/bin/zmprov gmi $1 | grep mailboxId: | awk '{ print $2 }')
lastdir=$(ls -t /opt/zimbra/store/0/$userid/msg/ | awk '{ print $1 }' | head -1)
echo "$(date +%T) Обработка ящика $1"
echo "$(date +%T) Номер ящика: $userid"
echo "$(date +%T) Создание дополнительной директории"
mkdir -p /media/storage2/$userid/msg
echo "$(date +%T) Начало переноса"
for (( dirid=0; dirid<$lastdir; dirid++ ))
do  
   echo "$(date +%T) Перемещение каталога номер $dirid"
   mv /opt/zimbra/store/0/$userid/msg/$dirid /media/storage2/$userid/msg/$dirid
   ln -s /media/storage2/$userid/msg/$dirid /opt/zimbra/store/0/$userid/msg/$dirid
   chown -R zimbra:zimbra /media/storage2/$userid/msg/$dirid
   chown -R zimbra:zimbra /opt/zimbra/store/0/$userid/msg/$dirid
   echo "$(date +%T) Перемещение каталога номер $dirid завершено"
done
