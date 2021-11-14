#!/bin/bash
# команда bash backup_users.sh users_list

zmprov=/opt/zimbra/bin/zmprov
password=000
backup=/root/tools/backup
contactfolder=/root/tools/backup/contacts
RED='\033[0;31m'
NC='\033[0m' # No Color


echo "$(date +%T): Начало бэкапирования учётных записей";
echo "";

echo "#!/bin/bash" > $backup/restoreUsers.sh
echo "" >> $backup/restoreUsers.sh
echo "chown -R zimbra:zimbra ./"  >> $backup/restoreUsers.sh
echo "" >> $backup/restoreUsers.sh
echo "RED='\033[0;31m'" >> $backup/restoreUsers.sh
echo "NC='\033[0m' # No Color" >> $backup/restoreUsers.sh
echo "" >> $backup/restoreUsers.sh

#for mbox in `$zmprov -l gaa | egrep -v 'avir|galsync|spam|ham|virus'`; do

cat $1 | while read mbox
do
    echo -e "$(date +%T): ${RED}Начато бэкапирование $mbox${NC}";
    
#Сбор контактной информации 
	givenName=$($zmprov -l ga $mbox givenName | grep givenName: | sed 's/givenName: //')
	sn=$($zmprov -l ga $mbox sn | grep sn: | sed 's/sn: //')
	displayName=$($zmprov -l ga $mbox displayName | grep displayName: | sed 's/displayName: //')
	userPassword=$($zmprov -l ga $mbox userPassword | grep userPassword: | sed 's/userPassword: //')
	telephoneNumber=$($zmprov -l ga $mbox telephoneNumber | grep telephoneNumber: | sed 's/telephoneNumber: //' | grep -v '+7 ()')
	mobile=$($zmprov -l ga $mbox mobile | grep mobile: | sed 's/mobile: //')
	company=$($zmprov -l ga $mbox company | grep company: | sed 's/company: //')
	title=$($zmprov -l ga $mbox title | grep title: | sed 's/title: //')
	street=$($zmprov -l ga $mbox street | grep street: | sed 's/street: //')
	l=$($zmprov -l ga $mbox l | grep l: | sed 's/l: //')
	postalCode=$($zmprov -l ga $mbox postalCode | grep postalCode: | sed 's/postalCode: //')
	zimbraPrefMailForwardingAddress=$($zmprov -l ga $mbox zimbraPrefMailForwardingAddress | grep zimbraPrefMailForwardingAddress: | sed 's/zimbraPrefMailForwardingAddress: //')

	echo "#Основные данные ящика $mbox" >>  $backup/restoreUsers.sh
	echo "echo -e \"\$(date +%T): \${RED}Начато восстановление ящика $mbox\${NC}\""  >>  $backup/restoreUsers.sh
	echo "sudo -u zimbra /opt/zimbra/bin/zmprov ca $mbox $password userPassword \"$userPassword\" zimbraPasswordMustChange FALSE displayName \"$displayName\" givenName \"$givenName\" sn \"$sn\" telephoneNumber \"$telephoneNumber\" mobile \"$mobile\" company \"$company\" title \"$title\" street \"$street\" l \"$l\" postalCode \"$postalCode\" zimbraPrefMailForwardingAddress \"$zimbraPrefMailForwardingAddress\"" >> $backup/restoreUsers.sh
	echo "echo \"\$(date +%T): ящик $mbox создан\"" >>  $backup/restoreUsers.sh
	echo "" >> $backup/restoreUsers.sh
	echo "$(date +%T): Контактная информация готова"	

#Копирование фильтров
	zmss=$($zmprov -l ga $mbox zimbraMailSieveScript | grep -v zimbraMailSieveScript: | grep -v "# name")
	
	echo "#Фильтры ящика $mbox" >> $backup/restoreUsers.sh
	echo "sudo -u zimbra $zmprov ma $mbox zimbraMailSieveScript 'require [\"fileinto\", \"copy\", \"reject\", \"tag\", \"flag\", \"variables\", \"log\", \"enotify\", \"envelope\", \"body\", \"ereject\", \"reject\", \"relational\", \"comparator-i;ascii-numeric\"]; $zmss'"  >> $backup/restoreUsers.sh	
	echo "" >> $backup/restoreUsers.sh
	echo "$(date +%T): Фильтры готовы"
	
#Копирование директорий
	echo "#Директории ящика $mbox" >> $backup/restoreUsers.sh
    	sudo -u zimbra /opt/zimbra/bin/zmmailbox -z -m $mbox gaf -v | grep \"path\": | sed 's/\"path\":\ \"//' | sed 's/\"\,//' | sed 's/^[ \t]*//' | grep -v "^/Briefcase$" | grep -v "^/Calendar$" | grep -v "^/Chats$" | grep -v "/Contacts$" | grep -v "^/Drafts$" | grep -v "^/Emailed Contacts$" | grep -v "^/Inbox$" | grep -v "^/Junk$" | grep -v "^/Sent$" | grep -v "^/Tasks$" | grep -v "^/Trash$"  | while read userdirs
	do
		echo "sudo -u zimbra /opt/zimbra/bin/zmmailbox -z -m $mbox cf \"$userdirs\"" >> $backup/restoreUsers.sh
	done
	echo "" >> $backup/restoreUsers.sh
	echo "$(date +%T): Директории готовы"
	
#Копирование контактов
	echo "#Контакты ящика $mbox" >> $backup/restoreUsers.sh
	mkdir $contactfolder/$mbox
    chown -R zimbra:zimbra $contactfolder/$mbox
	sudo -u zimbra /opt/zimbra/bin/zmmailbox -z -m $mbox gaf -v | grep \"defaultView\":\ \"contact\" -A 17 | grep \"path\": | sed 's/\"path\":\ \"//' | sed 's/\"\,//' | sed 's/^[ \t]*//' | while read contactDir
	do
	    echo "sudo -u zimbra /opt/zimbra/bin/zmmailbox -z -m $mbox df \"$contactDir\""  >> $backup/restoreUsers.sh
	    echo "sudo -u zimbra /opt/zimbra/bin/zmmailbox -z -m $mbox cf -V \"contact\" \"$contactDir\"" >> $backup/restoreUsers.sh
	    finDir=$(echo $contactDir | sed 's/ /_/g' | sed 's/\///g')
		sudo -u zimbra /opt/zimbra/bin/zmmailbox -z -m $mbox getRestURL "$contactDir/?fmt=tgz" > $contactfolder/$mbox/$finDir.tgz
		echo "su - zimbra -c 'zmmailbox -z -m $mbox postRestURL \"/?fmt=tgz&resolve=skip\" /opt/zimbra/restore/contacts/$mbox/$finDir.tgz'"  >> $backup/restoreUsers.sh
	done
	echo "" >> $backup/restoreUsers.sh
	echo "$(date +%T): Контакты готовы"

#Копирование алиасов
	echo "#Алиасы ящика $mbox" >> $backup/restoreUsers.sh
	for alias in `$zmprov ga $mbox | grep zimbraMailAlias | sed 's/zimbraMailAlias: //'`; do
		echo "su - zimbra -c \"zmprov aaa $mbox $alias\"" >> $backup/restoreUsers.sh
	done
	echo "$(date +%T): Алиасы готовы"	

	echo "" >> $backup/restoreUsers.sh
	echo "$(date +%T): Закончено бэкапирование $mbox";
	echo "";
done
cat restoreUsers.sh | grep -v 'cf "/"' | grep -v 'df "/Contacts"' | grep -v 'cf -V "contact" "/Contacts"' | grep -v 'df "/Emailed Contacts"' | grep -v 'cf -V "contact" "/Emailed Contacts"' > restore_users.sh
rm -f ./restoreUsers.sh
echo "$(date +%T): Окончание бэкапирования учётных записей";
