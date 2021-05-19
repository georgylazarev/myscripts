#!/bin/bash
zmprov='sudo -u zimbra /opt/zimbra/bin/zmprov'
typeOfScript=$1
typeTrigger=$3
typeOfSignature=$4
sigrenew='bash /opt/myscripts/sigrenew.sh'
# HELP
if [[ $typeOfScript == "--help" || $typeOfScript == "-h" || $typeOfScript == "help" ]]; then
  echo "";
  echo "Этот скрипт создает подпись ящика согласно контактынм данным";
  echo "";
  echo "Пример команды для одного ящика (!!!email обязательно вводить полностью!!!):";
  echo "bash sigcreate.sh -s email@domain.tld -t type";
  echo "Пример команды для списка ящиков:";
  echo "bash sigcreate.sh -l /path/to/list -t type";
  echo "";
  echo "-s - один ящик";
  echo "-l - список ящиков. Ящики в списке указываются по одному в строке.";
  echo "";
  echo "Возможные типы (-t):";
  echo "security - для подписи типа an-security.ru";
  echo "direct - для подписи типа an-direct.ru";
  echo "falck - для подписи типа falck.ru";
  echo "";
  exit;
fi

if [[ $typeTrigger == "-t" && $typeOfSignature == "security" ]]; then
  signatureName="security";
elif [[ $typeTrigger == "-t" && $typeOfSignature == "direct" ]]; then
  signatureName="direct";
elif [[ $typeTrigger == "-t" && $typeOfSignature == "falck" ]]; then
  signatureName="falck";
else
  echo "";
  echo "Вы ввели неверный параметр типа подписи.";
  echo "Возможные варианты: security, direct, falck";
  echo "";
  exit;
fi

if [[ $typeOfScript == "-s" ]]; then
  mbox=$2
  sigID=$($zmprov csig $mbox $signatureName);
  $zmprov mid $mbox default zimbraPrefDefaultSignatureId $sigID;
  $zmprov mid $mbox default zimbraPrefForwardReplySignatureId $sigID;
  $sigrenew -s $mbox -t $typeOfSignature;
elif [[ $typeOfScript == "-l" ]]; then
  cat $2 | while read mbox
  do
    sigID=$($zmprov csig $mbox $signatureName);
    $zmprov mid $mbox default zimbraPrefDefaultSignatureId $sigID;
    $zmprov mid $mbox default zimbraPrefForwardReplySignatureId $sigID;
    $sigrenew -s $mbox -t $typeOfSignature;
  done
else
  echo "";
  echo "Укажите параметр скрипта";
  echo "-s name@domain.tld - если нужно изменить один ящик";
  echo "";
  echo "-l путь к файлу со списком - если нужно изменить несколько ящиков";
  echo "";
  exit;
fi
