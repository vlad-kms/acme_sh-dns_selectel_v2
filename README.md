(Google translator works)
#### Now the DNS provider Selectel has two versions of the API: actual (v2) and legacy (v1).
#### Details: https://docs.selectel.ru/networks-services/dns/about-dns/

Description.
---
**Two DNS hosting and API versions are supported: v1 (legacy) and v2 (actual):**

https://docs.selectel.ru/networks-services/dns/about-dns/

To work, you need to define variables:

    export SL_Ver=v1    legacy version API
    OR
    export SL_Ver=v2    actual version API

Further, depending on the version, there is a different set of variables.

For SL_Ver=v1 (legacy):
    export SL_Key=<API_Key_SELECTEL>

For SL_Ver=v2 (actual):

    export SL_Login_ID=<id_user>
    export SL_Login_Name=<login_selectel_tech_account>
    export SL_Project_Name=<project_name>
    export SL_Pswd=<text>
    export SL_Expire='180'

About DNS hosting versions, Selectel tokens (API keys) and Keystone tokens on the site:

    __RU__
    https://developers.selectel.ru/docs/cloud-services/dns_api/dns_api_legacy/
    https://developers.selectel.ru/docs/control-panel/authorization/
    __EN__
    https://developers.selectel.com/docs/cloud-services/dns_api/dns_api_legacy/
    https://developers.selectel.com/docs/control-panel/authorization/

Details about variables:

    SL_Ver. Default: v2
        API version. This variable is relevant for the domain that acts as a test domain, and this domain must be registered in the appropriate DNS hosting (actual or legacy)
    
    SL_Expire. Default: 1400
        Lifetime of the received token for working with the API in minutes. Maximum 1440 (days). This is the limitation from the SELECTEL documentation:
            https://developers.selectel.ru/docs/control-panel/authorization/#%D1%82%D0%BE%D0%BA%D0%B5%D0%BD-keystone
        If set to 0, a new token will be generated for each API call.
        10-15 minutes is more than enough for one session

    The following variables are used during authorization to obtain a token.
    Read on the website:
        https://developers.selectel.ru/docs/cloud-services/dns_api/dns_api_actual/
        https://developers.selectel.ru/docs/control-panel/authorization/#%D1%82%D0%BE%D0%BA%D0%B5%D0%BD-keystone

        export SL_Login_Name=<login_selectel_tech_account>
        export SL_Project_Name=<project_name>
        export SL_Pswd=<text>
        export SL_Login_ID=<id_user>

_______________________________
_______________________________
-----------

#### Теперь ДНС провайдер Selectel имеет две версии API actual (v2) и legacy (v1).
#### Подробно: https://docs.selectel.ru/networks-services/dns/about-dns/

Описание.
---
Подерживается две версии API: v1 (legacy) и v2 (actual):

https://docs.selectel.ru/networks-services/dns/about-dns/

Для работы необходимо определить переменные:

    export SL_Ver=v1    legacy версия API
    ИЛИ
    export SL_Ver=v2    actual версия API

Далее, в зависимости от версии, разный набор переменных.

Для SL_Ver=v1 (legacy):

    export SL_Key=<API_Key_SELECTEL>
    
Для v2 (actual)). Определили SL_Ver=v2:

    export SL_Login_ID=<id_user>
    export SL_Login_Name=<login_selectel_tech_account>
    export SL_Project_Name=<project_name>
    export SL_Pswd=<text>
    export SL_Expire='180'


Про версии DNS хостинга, токены Selectel (ключи API) и токены Keystone на сайте:

    RU
    https://developers.selectel.ru/docs/cloud-services/dns_api/dns_api_legacy/
    https://developers.selectel.ru/docs/control-panel/authorization/
    EN
    https://developers.selectel.com/docs/cloud-services/dns_api/dns_api_legacy/
    https://developers.selectel.com/docs/control-panel/authorization/


Подробно про переменные:

    SL_Ver
        версия API. Эта переменная актуальна для домена, который выступает в качестве проверочногои этот домен должен быть зарегистрирован в соответсвующем DNS хостинге (actual or legacy)

    SL_Expire
        Время жизни полученного токена для работы с API в минутах. Максимум 1440 (сутки).
        Это ограничение из документации SELECTEL:
            https://developers.selectel.ru/docs/control-panel/authorization/#%D1%82%D0%BE%D0%BA%D0%B5%D0%BD-keystone

            Если установлено в 0, то на каждый вызов API будет генерироваться новый токен.
            Для одной сессии более чем достаточно 10-15 минут

    Следующие переменные используются при авторизации для получения токена.
    Почитать на сайте:

        https://developers.selectel.ru/docs/cloud-services/dns_api/dns_api_actual/
        https://developers.selectel.ru/docs/control-panel/authorization/#%D1%82%D0%BE%D0%BA%D0%B5%D0%BD-keystone
        
        export SL_Login_Name=<login_selectel_tech_account>
        export SL_Project_Name=<project_name>
        export SL_Pswd=<text>
        export SL_Login_ID=<id_user>
