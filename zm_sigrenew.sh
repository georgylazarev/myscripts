#!/bin/bash
zmprov='sudo -u zimbra /opt/zimbra/bin/zmprov'
typeOfScript=$1
typeTrigger=$3
typeOfSignature=$4

# HELP
if [[ $typeOfScript == "--help" || $typeOfScript == "-h" || $typeOfScript == "help" ]]; then
  echo "";
  echo "Этот скрипт обновляет подпись ящика согласно контактынм данным";
  echo "";
  echo "Пример команды для одного ящика (!!!email обязательно вводить полностью!!!):";
  echo "bash sigrenew.sh -s email@domain.tld -t type";
  echo "Пример команды для списка ящиков:";
  echo "bash sigrenew.sh -l /path/to/list -t type";
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

#SOCIAL LINKS BLOCK
blockNine="<div style='margin-top: 5pt;'><span style='text-decoration: underline;'>Подписывайтесь на нас:</span><br /><br /><a target='_blank' href='https://instagram.com/an_security'><img src='https://an-security.ru/img/header/insta_an-security.png' alt='Ссылка на страницу в Instagram' /></a><br /><a target='_blank' href='https://vk.com/ansecurity'><img src='https://an-security.ru/img/header/vk_an-security.png' alt='Ссылка на страницу в ВК' /></a></div>";

# TYPE OF SIGNATURE
if [[ $typeTrigger == "-t" && $typeOfSignature == "security" ]]; then
  signatureName="security";
  blockSeven="<div><a href='https://an-security.ru' target='_blank' style='color: #1155cc;'>an-security.ru</a></div>";
  blockEight="<div><a href='https://an-security.ru' target='_blank'><img src='https://an-security.ru/img/header/logo-email.png' width='200px' height='auto' alt='Логотип AN-Security' /></a></div>";
elif [[ $typeTrigger == "-t" && $typeOfSignature == "direct" ]]; then
  signatureName="direct";
  blockSeven="<div><a href='https://an-direct.ru' target='_blank' style='color: #1155cc;'>an-direct.ru</a></div>";
  blockEight="<div><a href='https://an-direct.ru' target='_blank'><img src='https://an-security.ru/img/header/direct-logo-200.png' width='200px' height='auto'  alt='Логотип AN-Direct'></a></div>";
elif [[ $typeTrigger == "-t" && $typeOfSignature == "falck" ]]; then
  signatureName="falck";
  blockSeven="<div><a href='https://falck.tech' target='_blank' style='color: #1155cc;'>falck.tech</a></div>";
  blockEight="<div><a href='https://falck.tech' target='_blank'><img src='https://an-security.ru/img/header/falck-logo-200.png' width='200px' height='auto' alt='Логотип Falck'></a></div>";
else
  echo "";
  echo "Вы ввели неверный параметр типа подписи.";
  echo "Возможные варианты: security, direct, falck";
  echo "";
  exit;
fi

if [[ $typeOfScript == "-s" ]]; then
  mbox=$2
  echo "";
  echo "$(date +%T): Сбор информации для профиля $mbox";
  #сбор информации из профиля
  displayName=`$zmprov -l ga $mbox displayName | grep displayName: | sed 's/displayName: //'`;
  echo "          ФИО: $displayName";
  if [[ -n $displayName ]]; then
    blockOne="<div style='margin-top: 5pt;'>$displayName</div>";
  else 
    echo "Не указано имя, это обязательный параметр!";
    exit;
  fi

  title=`$zmprov -l ga $mbox title | grep title: | sed 's/title: //'`;
  echo "          Должность: $title";
  if [[ -n $title ]]; then
    blockTwo="<div>$title</div>";
  else
    blockTwo="";
  fi

  mobile=`$zmprov -l ga $mbox mobile | grep mobile: | sed 's/mobile: //'`;
  echo "          Мобильный: $mobile";
  if [[ -n $mobile ]]; then
    blockThree="<div>$mobile</div>";
  else
    blockThree="";
  fi

  blockFour="<div><a href='mailto:$mbox' target='_blank' style='color: #1155cc;'>$mbox</a></div>"
  
  l=`$zmprov -l ga $mbox l | grep l: | sed 's/l: //'`;
  echo "          Город: $l";
  street=`$zmprov -l ga $mbox street | grep street: | sed 's/street: //'`;
  echo "          Адрес: $street";
  if [[ -n $l && -n $street ]]; then
    blockFive="<div>$l, $street</div>";
  elif [[ -z $l && -n $street ]]; then
    blockFive="<div>$street</div>";
  elif [[ -n $l && -z $street ]]; then
    blockFive="<div>$l</div>";
  else
    blockFive="";
  fi
    
  telephoneNumber=`$zmprov -l ga $mbox telephoneNumber | grep telephoneNumber: | sed 's/telephoneNumber: //' | sed 's/ x/, доб\./'`;
  if [[ -n $telephoneNumber ]]; then
    blockSix="<div>$telephoneNumber</div>";
  else
    blockSix="";
  fi
  echo "          Телефон: $telephoneNumber";
  
  echo "$(date +%T): Применение изменений";
  newSignature="<div style='color: #264796; font-family: arial,helvetica,sans-serif; font-size: 10pt;'><div style='margin-bottom: 5pt;'><div>---</div><div>С уважением,</div></div><div style='margin-bottom: 5pt;'>$blockOne $blockTwo</div><div style='margin-bottom: 5pt;'>$blockThree $blockFour</div><div style='margin-bottom: 5pt;'>$blockFive $blockSix</div><div>$blockSeven $blockEight</div></div>";
  $zmprov msig $mbox $signatureName zimbraPrefMailSignature ""
  $zmprov msig $mbox $signatureName zimbraPrefMailSignatureHTML "$newSignature"
  
  echo "$(date +%T): ящик $mbox готов";
  echo "";
elif [[ $typeOfScript == "-l" ]]; then
  cat $2 | while read mbox
  do
    echo "";
    echo "$(date +%T): Сбор информации для профиля $mbox";
    #сбор информации из профиля
    displayName=`$zmprov -l ga $mbox displayName | grep displayName: | sed 's/displayName: //'`;
    echo "          ФИО: $displayName";
    if [[ -n $displayName ]]; then
      blockOne="<div style='margin-top: 5pt;'>$displayName</div>";
    else 
      echo "Не указано имя, это обязательный параметр!";
      exit;
    fi

    title=`$zmprov -l ga $mbox title | grep title: | sed 's/title: //'`;
    echo "          Должность: $title";
    if [[ -n $title ]]; then
      blockTwo="<div>$title</div>";
    else
      blockTwo="";
    fi

    mobile=`$zmprov -l ga $mbox mobile | grep mobile: | sed 's/mobile: //'`;
    echo "          Мобильный: $mobile";
    if [[ -n $mobile ]]; then
      blockThree="<div>$mobile</div>";
    else
      blockThree="";
    fi

    blockFour="<div><a href='mailto:$mbox' target='_blank' style='color: #1155cc;'>$mbox</a></div>"
    
    l=`$zmprov -l ga $mbox l | grep l: | sed 's/l: //'`;
    echo "          Город: $l";
    street=`$zmprov -l ga $mbox street | grep street: | sed 's/street: //'`;
    echo "          Адрес: $street";
    if [[ -n $l && -n $street ]]; then
      blockFive="<div>$l, $street</div>";
    elif [[ -z $l && -n $street ]]; then
      blockFive="<div>$street</div>";
    elif [[ -n $l && -z $street ]]; then
      blockFive="<div>$l</div>";
    else
      blockFive="";
    fi
      
    telephoneNumber=`$zmprov -l ga $mbox telephoneNumber | grep telephoneNumber: | sed 's/telephoneNumber: //' | sed 's/ x/, доб\./'`;
    if [[ -n $telephoneNumber ]]; then
      blockSix="<div>$telephoneNumber</div>";
    else
      blockSix="";
    fi
    echo "          Телефон: $telephoneNumber";
    
    echo "$(date +%T): Применение изменений";
    newSignature="<div style='color: #264796; font-family: arial,helvetica,sans-serif; font-size: 10pt;'><div style='margin-bottom: 5pt;'><div>---</div><div>С уважением,</div></div><div style='margin-bottom: 5pt;'>$blockOne $blockTwo</div><div style='margin-bottom: 5pt;'>$blockThree $blockFour</div><div style='margin-bottom: 5pt;'>$blockFive $blockSix</div><div>$blockSeven $blockEight</div><div>$blockNine</div></div>";
    $zmprov msig $mbox $signatureName zimbraPrefMailSignature ""
    $zmprov msig $mbox $signatureName zimbraPrefMailSignatureHTML "$newSignature"
    
    echo "$(date +%T): ящик $mbox готов";
    echo "";
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
