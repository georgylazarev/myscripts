#!/bin/bash
zmprov='sudo -u zimbra /opt/zimbra/bin/zmprov';
signatureName="security21";

blockZero="<div style='color: #264796; font-family: arial,helvetica,sans-serif; font-size: 10pt;'><div>---</div><div>С уважением,</div>";
blockSeven="<div style='margin-top: 16px;'>Подписывайтесь на нас:<br /><a target='_blank' href='https://instagram.com/an_security' rel='noopener'><img src='https://an-security.ru/img/header/instagram-logo.png' alt='Ссылка на страницу в Instagram' width='32' height='32' style='margin: 8px; margin-left: 0;' /></a><a target='_blank' href='https://vk.com/ansecurity' rel='noopener'><img src='https://an-security.ru/img/header/vk-logo.png' alt='Ссылка на страницу в ВК' width='32' height='32' style='margin: 8px;' /></a></div></div>";

cat $1 | while read mbox
do
  status=`$zmprov ga $mbox zimbraAccountStatus | grep '^zimbraAccountStatus' | awk '{ print $2 }'`;
  if [[ $status == 'active' ]]; then
    echo "";
    echo "$(date +%T): Сбор информации для профиля $mbox";
    echo "          Статус: $status";

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
      blockThree="<div style='margin-top: 5pt;'>$mobile</div>";
    else
      blockThree="";
    fi

    blockFour="<div><a href='mailto:$mbox' target='_blank' style='color: #1155cc;'>$mbox</a></div>";

    l=`$zmprov -l ga $mbox l | grep l: | sed 's/l: //'`;
    echo "          Город: $l";
    if [[ -n $l ]]; then
      blockFive="<div>$l</div>";
    else
      blockFive="";
    fi

    typeOfEmail=$($zmprov ga $mbox company | grep '^company:' | awk '{print $2}' | sed 's/,//');
    echo "          Тип профиля: $typeOfEmail";
    if [[ $typeOfEmail == "Директ" ]]; then
      blockSix="<div  style='margin-top: 5pt;'><a href='https://an-direct.ru' target='_blank' rel='noopener'><img src='https://an-security.ru/img/header/direct-logo-200.png' width='200px' height='auto' alt='Логотип AN-Security Директ' /></a></div>";
    elif [[ $typeOfEmail == "Фальк" ]]; then
      blockSix="<div  style='margin-top: 5pt;'><a href='https://falck.tech' target='_blank' rel='noopener'><img src='https://an-security.ru/img/header/falck-logo-200.png' width='200px' height='auto' alt='Логотип Фальк Техникс' /></a></div>";
    else
      blockSix="<div  style='margin-top: 5pt;'><a href='https://an-security.ru' target='_blank' rel='noopener'><img src='https://an-security.ru/img/header/logo-email.png' width='200px' height='auto' alt='Логотип AN-Security' /></a></div>";
    fi

    echo "$(date +%T): Применение изменений";

    newSignature="$blockZero $blockOne $blockTwo $blockThree $blockFour $blockFive $blockSix $blockSeven";
    
    sigID=$($zmprov csig $mbox $signatureName);
    $zmprov mid $mbox default zimbraPrefDefaultSignatureId $sigID;
    $zmprov mid $mbox default zimbraPrefForwardReplySignatureId $sigID;
    
    $zmprov msig $mbox $signatureName zimbraPrefMailSignature ""
    $zmprov msig $mbox $signatureName zimbraPrefMailSignatureHTML "$newSignature"

    echo "$(date +%T): ящик $mbox готов";
    echo "";
  fi
done
echo "$(date +%T): Все ящики готовы";
echo "";
