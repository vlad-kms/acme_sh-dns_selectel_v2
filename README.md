#### DNS hosting from the Selectel provider has switched to using the actual (v2) API version. Legacy v1 has been closed
#### Details: https://docs.selectel.ru/networks-services/dns/about-dns/

Description.

Changes to this project have been officially added to asme.sh: https://github.com/acmesh-official/acme.sh
(https://github.com/acmesh-official/acme.sh/pull/5128)
Now all questions and changes are there.

---
#### DNS hosting от провайдера Selectel перешел к использованиию версии API actual (v2). Legacy v1 закрыли
#### Подробно: https://docs.selectel.ru/networks-services/dns/about-dns/

Описание.

Изменения этого проекта внесены официально в asme.sh: https://github.com/acmesh-official/acme.sh
(https://github.com/acmesh-official/acme.sh/pull/5128)
Теперь все вопросы и изменения там.

---
---
## Deprecated. Do not use.

Подерживается две версии API: v1 (legacy) и v2 (actual):

https://docs.selectel.ru/networks-services/dns/about-dns/

Для работы необходимо определить переменные:

    export SL_Ver=v1    legacy версия API
    ИЛИ
    export SL_Ver=v2    actual версия API

Далее, в зависимости от версии, разный набор переменных.
v1 является значением по-умолчанию, если не определена переменная SL_Ver1, то будет использоваться v1

Для SL_Ver=v1 (legacy) надо определить следующие переменные:

    export SL_Key=<API_Key_SELECTEL>

Для SL_Ver=v2 (actual) надо определить следующие переменные:

    export SL_Login_ID=<id_user>
    export SL_Login_Name=<login_selectel_service_account>
    export SL_Project_Name=<project_name>
    export SL_Pswd=<text>
    export SL_Expire='180'

__*Для старых инсталляций ничего не меняется, и они будут работать как и раньше. Т.е. достаточно определить только SL_Key*__

Про версии DNS хостинга, токены Selectel (ключи API) и токены Keystone на сайте:

    RU
    https://developers.selectel.ru/docs/cloud-services/dns_api/dns_api_legacy/
    https://developers.selectel.ru/docs/control-panel/authorization/
    EN
    https://developers.selectel.com/docs/cloud-services/dns_api/dns_api_legacy/
    https://developers.selectel.com/docs/control-panel/authorization/


Подробно про переменные:

    SL_Ver
        версия API. Эта переменная актуальна для домена, который выступает в качестве проверочного и этот домен должен быть зарегистрирован в соответсвующем DNS хостинге (actual or legacy)
        По-умолчанию: v1

    SL_Expire
        Время жизни полученного токена для работы с API в минутах. Максимум 1440 (сутки).
        Это ограничение из документации SELECTEL:
            https://developers.selectel.ru/docs/control-panel/authorization/#%D1%82%D0%BE%D0%BA%D0%B5%D0%BD-keystone

            Если установлено в 0, то на каждый вызов API будет генерироваться новый токен.
            Для одной сессии более чем достаточно 10-15 минут
        По-умолчанию: 1400

    Следующие переменные используются при авторизации для получения Keystone токена.
        
        export SL_Login_Name=<login_selectel_service_account>
        export SL_Project_Name=<project_name>
        export SL_Pswd=<text>
        export SL_Login_ID=<id_user>

        Почитать на сайте:
        https://developers.selectel.ru/docs/cloud-services/dns_api/dns_api_actual/
        https://developers.selectel.ru/docs/control-panel/authorization/#%D1%82%D0%BE%D0%BA%D0%B5%D0%BD-keystone
_______________________________
_______________________________
## Инсталляция
Пока acmesh-official не вмерджил мои изменения к себе:
Из репозитория скопировать dnsapi/dns_selectel.sh в <КаталогУстановки_acme.sh/dnsapi/dns_selectel> (внимание, без расширения .sh). Это позволит использовать файл dns_selectel вместо dns_selectel.sh (предыдущей версии) и сохранять файл dns_selectel и после upgrade.
