# acme_sh-dns_selectel_v2
Установка.
---
Заменить в каталоге acme.sh/dnsapi файл dns_selectel.sh

Описание.
---
Подерживается две версии API: v1 (legacy) и v2 (actual):

https://docs.selectel.ru/networks-services/dns/about-dns/

Для v1 описание актуально https://github.com/acmesh-official/acme.sh/wiki/dnsapi, только надо добавить еще одну переменную:

    export SL_Ver=v1    версия API

Для v2 все аналогично, только используются новый алгоритм и другие переменные:
1) создать проект, создать технологическую УЗ по документации с сайта https://selectel.ru;

2) проинициализировать требуемые переменные

    export SL_Ver='v2'
        
        версия API. Эта переменная актуальна для домена, который выступает в качестве проверочного:
        
        export SL_Ver=v2; ./acme.sh --issue -d dom1.ru -d *.dom2.ru --challenge-alias t.dom.ru --dns dns_selectel, здесь домен t.dom.ru должен быть зарегистрирован в actual DNS (v2)

        export SL_Ver=v1; ./acme.sh --issue -d dom1.ru -d *.dom1.ru --dns dns_selectel, здесь домен dom1.ru должен быть зарегистрирован в legacy DNS (v1)

        Нельзя получить сертификаты в одной команде для разных версий DNS, если только не используется --challenge-alias

    export SL_Expire='180'

        Время жизни полученного токена для работы с API в минутах. Максимум 1440 (сутки).
        Это ограничение из документации SELECTEL:
            https://developers.selectel.ru/docs/control-panel/authorization/#%D1%82%D0%BE%D0%BA%D0%B5%D0%BD-keystone

        Если установлено в 0, то на каждый вызов API будет генерироваться новый токен.
        Для одной сессии более чем достаточно 10-15 минут

    Следующие переменные используются при авторизации для получения токена.
    Почитать на сайте:
    https://developers.selectel.ru/docs/cloud-services/dns_api/dns_api_actual/
        
    https://developers.selectel.ru/docs/control-panel/authorization/#%D1%82%D0%BE%D0%BA%D0%B5%D0%BD-keystone

    export SL_Login_Name=<login_from_selectel_techno_account>

    export SL_Project_Name=<project_name>

    export SL_Pswd=<text>

    export SL_Login_ID=<id_system_user>
    
