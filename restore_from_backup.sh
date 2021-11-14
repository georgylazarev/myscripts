mbox=$1;
zmbox='/opt/zimbra/bin/zmmailbox';
backupFolder='/opt/zimbra/backup/backups/$mbox';

for file in `find $backupFolder -type f -name "*.tgz"`
do
  echo $file;
  echo " ";
  #$zmbox -z -m $mbox -t 0 postRestURL "//?fmt=tgz&resolve=skip" $backup/$file
done
