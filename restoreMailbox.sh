#!/bin/bash

zmbox=/opt/zimbra/bin/zmmailbox
zmprov=/opt/zimbra/bin/zmprov

backup=$2 # Путь до архива, включая название файла 
mbox=$1 # Ящик, куда производится восстановление
echo "$(date +%T): Начало восстановления писем для $mbox";
$zmbox -z -m $mbox -t 0 postRestURL "//?fmt=tgz&resolve=skip" $backup
echo "$(date +%T): Окончание восстановления писем для $mbox";
