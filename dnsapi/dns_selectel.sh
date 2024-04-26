#!/usr/bin/sh

# Протестировано (примеры):
#   Исходные данные:
#     dv1.ru - зарегистрированный домен в legacy v1
#     t.dv2.ru - зарегистрированный домен в actual v2
# export SL_Ver=v1; ./acme.sh --issue -d t.dv2.ru -d *.t.dv2.ru --domain-alias test11.dv1.ru --dns dns_selectel
# export SL_Ver=v1; ./acme.sh --issue -d t.dv2.ru -d *.t.dv2.ru --challenge-alias dv1.ru --dns dns_selectel
# export SL_Ver=v1; ./acme.sh --issue -d dv1.ru --dns dns_selectel
# export SL_Ver=v1; ./acme.sh --issue -d dv1.ru -d *.dv1.ru --dns dns_selectel
# export SL_Ver=v1; ./acme.sh --issue -d dv1.ru -d *.dv1.ru --dns dns_selectel
#
# export SL_Ver=v2; ./acme.sh --issue -d t.dv2.ru --dns dns_selectel
# export SL_Ver=v2; ./acme.sh --issue -d t.dv2.ru -d *.t.dv2.ru --dns dns_selectel
# export SL_Ver=v2; ./acme.sh --issue -d dv1.ru --challenge-alias t.dv2.ru --dns dns_selectel
# export SL_Ver=v2; ./acme.sh --issue -d dv1.ru -d *.dv1.ru --challenge-alias t.dv2.ru --dns dns_selectel
# export SL_Ver=v2; ./acme.sh --issue -d dv1.ru -d *.dv1.ru --domain-alias ta1.t.dv2.ru --dns dns_selectel

#
#export SL_Key="sdfsdfsdfljlbjkljlkjsdfoiwje"
#export SL_Ver="v1"
#export SL_Expire=60        - время жизни token в минутах, по-умолчанию: 60 минут
#export SL_Login_name=''    - имя сервисного пользователя, например: dns
#export SL_Login_ID=''      - id пользователя ( не сервисного), например: 218200
#export SL_Project_Name=''  - имя проекта, например: dns_t_mrovo_ru
#export SL_Pswd='pswd'      - пароль сервисного пользователя, например: пароль
#

SL_Api="https://api.selectel.ru/domains"
auth_uri="https://cloud.api.selcloud.ru/identity/v3/auth/tokens"
_sl_sep='#'

########  Public functions #####################

#Usage: add  _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
dns_selectel_add() {
  fulldomain=$1
  txtvalue=$2

  #if ! _sl_init_vars; then
  if ! _sl_init_vars; then
    return 1
  fi
  _debug2 SL_Ver "$SL_Ver"
  _secure_debug3 SL_Key "$SL_Key"
  _debug2 SL_Expire "$SL_Expire"
  _debug2 SL_Login_Name "$SL_Login_Name"
  _debug2 SL_Login_ID "$SL_Login_ID"
  _debug2 SL_Project_Name "$SL_Project_Name"

  _debug "First detect the root zone"
  if ! _get_root "$fulldomain"; then
    _err "invalid domain"
    return 1
  fi
  _debug _domain_id "$_domain_id"
  _debug _sub_domain "$_sub_domain"
  _debug _domain "$_domain"

  _info "Adding record"
  if [ "$SL_Ver" = "v2" ]; then
    _ext_srv1="/zones/"
    _ext_srv2="/rrset/"
    _text_tmp=$(echo "$txtvalue" | sed -En "s/[\"]*([^\"]*)/\1/p")
    _debug txtvalue "$txtvalue"
    _text_tmp='\"'$_text_tmp'\"'
    _debug _text_tmp "$_text_tmp"
    _data="{\"type\": \"TXT\", \"ttl\": 60, \"name\": \"${fulldomain}.\", \"records\": [{\"content\":\"$_text_tmp\"}]}"
  elif [ "$SL_Ver" = "v1" ]; then
    _ext_srv1="/"
    _ext_srv2="/records/"
    _data="{\"type\":\"TXT\",\"ttl\":60,\"name\":\"$fulldomain\",\"content\":\"$txtvalue\"}"
  else
    #not valid
    _err "Error. Unsupported version API $SL_Ver"
    return 1
  fi
  _ext_uri="${_ext_srv1}$_domain_id${_ext_srv2}"
  _debug3 _ext_uri "$_ext_uri"
  _debug3 _data "$_data"

  if _sl_rest POST "$_ext_uri" "$_data"; then
    if _contains "$response" "$txtvalue"; then
        _info "Added, OK"
        return 0
    fi
    if _contains "$response" "already_exists"; then
      if [ "$SL_Ver" = "v2" ]; then
        # надо добавить к существующей записи еще один content
        # 1) найти и считать запись $fulldomain
        #     {
        #       "id":"300223f5-0a37-49c5-a44e-5294108a93b4","name":"tt1.t.mrovo.ru.","ttl":3600,"type":"TXT",
        #       "records":[
        #         {"content":"\"text2\"","disabled":false},
        #         {"content":"\"text1\"","disabled":false}
        #       ],
        #       "comment":null,"managed_by":null,"zone_id":"70d5d06b-1957-4e6c-ab3e-a31dd5cde10c"
        #     }
        # 2) добавить новую подзапись в нее
        #     {
        #       "id":"300223f5-0a37-49c5-a44e-5294108a93b4","name":"tt1.t.mrovo.ru.","ttl":3600,"type":"TXT",
        #       "records":[
        #         {"content":"\"text2\"","disabled":false},
        #         {"content":"\"text1\"","disabled":false},
        #         {"content":"\"${txtvalue}\"","disabled":false}
        #       ],
        #       "comment":null,"managed_by":null,"zone_id":"70d5d06b-1957-4e6c-ab3e-a31dd5cde10c"
        #     }
        # считали записи rrset
        _debug "Getting txt records"
        _sl_rest GET "${_ext_uri}"
        # проверить существование записи с именем $fulldomain. Вообще-то излишне, но вдруг
        #if ! _contains "$response" "$fulldomain"; then
        #  _err "Txt record ${fulldomain} not found"
        #  return 1
        #fi
        # Если в данной записи, есть текстовое значение $txtvalue,
        # то все хорошо, добавлять ничего не надо и результат успешный
        if _contains "$response" "$txtvalue"; then
          _info "Added, OK"
          _info "Txt record ${fulldomain} со значением ${txtvalue} already exists"
          return 0
        fi
        # группа \1 - полная запись rrset; группа \2 - значение records:[{"content":"\"v1\""},{"content":"\"v2\""}",...], а именно {"content":"\"v1\""},{"content":"\"v2\""}",...
        _record_seg="$(echo "$response" | sed -En "s/.*(\{\"id\"[^}]*${fulldomain}[^}]*records[^}]*\[(\{[^]]*\})\][^}]*}).*/\1/p")"
        _record_array="$(echo "$response" | sed -En "s/.*(\{\"id\"[^}]*${fulldomain}[^}]*records[^}]*\[(\{[^]]*\})\][^}]*}).*/\2/p")"
        # record id
        _record_id="$(echo "$_record_seg" | tr "," "\n" | tr "}" "\n" | tr -d " " | grep "\"id\"" | cut -d : -f 2)"
        # delete starts and ends '"'
        _record_id="$(echo "${_record_id}" | sed -En "s/^[\"]*([^\"]*).*$/\1/p")"
        _tmp_str="${_record_array},{\"content\":\"${_text_tmp}\"}"
        _data="{\"ttl\": 60, \"records\": [${_tmp_str}]}"
        _debug3 _record_seg "$_record_seg"
        _debug3 _record_array "$_record_array"
        _debug3 _record_array "$_record_id"
        _debug3 _data "$_data"
        # вызов REST API PATCH
        if _sl_rest PATCH "${_ext_uri}${_record_id}" "$_data"; then
          _info "Added, OK"
          return 0
        fi
      elif [ "$SL_Ver" = "v1" ]; then
        _info "Added, OK"
        return 0
      fi
    fi
  fi
  _err "Add txt record error."
  return 1
}

#fulldomain txtvalue
dns_selectel_rm() {
  #TODO пока для версии v2 (actual) удаляет за один раз всю группу записи _acme-callenge.domain ($fulldomain)
  #TODO т.е. если на другом сервере одновременно создал запись с таким же именем, то могут быть коллизии
  #TODO надо реализовать удаление одной записи из records:[{content="\"text1\""},{content="\"text2\""},...]
  # это не критично, т.к. вероятность такая очень мала
  fulldomain=$1
  txtvalue=$2

  #SL_Key="${SL_Key:-$(_readaccountconf_mutable SL_Key)}"
  if ! _sl_init_vars "nosave"; then
    return 1
  fi
  _debug2 SL_Ver "$SL_Ver"
  _secure_debug3 SL_Key "$SL_Key"
  _debug2 SL_Expire "$SL_Expire"
  _debug2 SL_Login_Name "$SL_Login_Name"
  _debug2 SL_Login_ID "$SL_Login_ID"
  _debug2 SL_Project_Name "$SL_Project_Name"

  _debug "First detect the root zone"
  if ! _get_root "$fulldomain"; then
    _err "invalid domain"
    return 1
  fi
  _debug _domain_id "$_domain_id"
  _debug _sub_domain "$_sub_domain"
  _debug _domain "$_domain"

  if [ "$SL_Ver" = "v2" ]; then
    _ext_srv1="/zones/"
    _ext_srv2="/rrset/"
  elif [ "$SL_Ver" = "v1" ]; then
    _ext_srv1="/"
    _ext_srv2="/records/"
  else
    #not valid
    _err "Error. Unsupported version API $SL_Ver"
    return 1
  fi

  _debug "Getting txt records"
  _ext_uri="${_ext_srv1}$_domain_id${_ext_srv2}"
  _debug3 _ext_uri "$_ext_uri"
  _sl_rest GET "${_ext_uri}"

  if ! _contains "$response" "$txtvalue"; then
    _err "Txt record not found"
    return 1
  fi

  if [ "$SL_Ver" = "v2" ]; then
    _record_seg="$(echo "$response" | sed -En "s/.*(\{\"id\"[^}]*records[^[]*(\[\{[^]]*${txtvalue}[^]]*\])[^}]*}).*/\1--\2/p")"
    # record id
    #_record_id="$(echo "$_record_seg" | tr "," "\n" | tr "}" "\n" | tr -d " " | grep "\"id\"" | cut -d : -f 2)"
  elif [ "$SL_Ver" = "v1" ]; then
    _record_seg="$(echo "$response" | _egrep_o "[^{]*\"content\" *: *\"$txtvalue\"[^}]*}")"
    # record id
    #_record_id="$(echo "$_record_seg" | tr "," "\n" | tr "}" "\n" | tr -d " " | grep "\"id\"" | cut -d : -f 2)"
  else
    #not valid
    _err "Error. Unsupported version API $SL_Ver"
    return 1
  fi
  _debug3 "_record_seg" "$_record_seg"
  if [ -z "$_record_seg" ]; then
    _err "can not find _record_seg"
    return 1
  fi
  # record id
  _record_id="$(echo "$_record_seg" | tr "," "\n" | tr "}" "\n" | tr -d " " | grep "\"id\"" | cut -d : -f 2)"
  if [ -z "$_record_id" ]; then
    _err "can not find _record_id"
    return 1
  fi
  # delete starts and ends '"'
  _record_id="$(echo "${_record_id}" | sed -En "s/^[\"]*([^\"]*).*$/\1/p")"
  _debug3 "_record_id" "$_record_id"

  # delete all record type TXT with text $txtvalue
  for _one_id in $_record_id; do
    _del_uri="${_ext_uri}${_one_id}"
    _debug2 _ext_uri "$_del_uri"
    if ! _sl_rest DELETE "${_del_uri}"; then
      _err "Delete record error: ${_del_uri}."
    else
      info "Delete record success: ${_del_uri}."
    fi
  done
  return 0
}

####################  Private functions below ##################################
#_acme-challenge.www.domain.com
#returns
# _sub_domain=_acme-challenge.www
# _domain=domain.com
# _domain_id=sdjkglgdfewsdfg
_get_root() {
  domain=$1

  if [ "$SL_Ver" = 'v1' ]; then
    # version API 1
    if ! _sl_rest GET "/"; then
      return 1
    fi
    i=2
    p=1
    while true; do
      #h=$(printf "%s" "$domain" | cut -d . -f $i-100)
      h=$(printf "%s" "$domain" | cut -d . -f "$i"-100)
      _debug h "$h"
      if [ -z "$h" ]; then
        #not valid
        return 1
      fi

      if _contains "$response" "\"name\" *: *\"$h\","; then
        #_sub_domain=$(printf "%s" "$domain" | cut -d . -f 1-$p)
        _sub_domain=$(printf "%s" "$domain" | cut -d . -f 1-"$p")
        _domain=$h
        _debug "Getting domain id for $h"
        if ! _sl_rest GET "/$h"; then
        _err "Error read records of all domains $SL_Ver"
          return 1
        fi
        _domain_id="$(echo "$response" | tr "," "\n" | tr "}" "\n" | tr -d " " | grep "\"id\":" | cut -d : -f 2)"
        return 0
      fi
      p=$i
      i=$(_math "$i" + 1)
    done
    _err "Error read records of all domains $SL_Ver"
    return 1
  elif [ "$SL_Ver" = "v2" ]; then
    # version API 2
    _ext_uri='/zones/'
    domain="${domain}."
    _debug "domain:: " "$domain"
    # read records of all domains
    if ! _sl_rest GET "$_ext_uri"; then
        #not valid
      _err "Error read records of all domains $SL_Ver"
      return 1
    fi
    i=2
    p=1
    while true; do
      h=$(printf "%s" "$domain" | cut -d . -f "$i"-100)
      _debug h "$h"
      if [ -z "$h" ]; then
        #not valid
        _err "The domain was not found among the registered ones"
        return 1
      fi

      _domain_record=$(echo "$response" | sed -En "s/.*(\{[^}]*id[^}]*\"name\" *: *\"$h\"[^}]*}).*/\1/p")
      _debug "_domain_record:: " "$_domain_record"
      if [ -n "$_domain_record" ]; then
        _sub_domain=$(printf "%s" "$domain" | cut -d . -f 1-"$p")
        _domain=$h
        _debug "Getting domain id for $h"
        #_domain_id="$(echo "$_domain_record" | tr "," "\n" | tr "}" "\n" | tr -d " " | grep "\"id\":" | cut -d : -f 2 | sed -En "s/\"([^\"]*)\"/\1\p")"
        _domain_id=$(echo "$_domain_record" | sed -En "s/\{[^}]*\"id\" *: *\"([^\"]*)\"[^}]*\}/\1/p")
        return 0
      fi
      p=$i
      i=$(_math "$i" + 1)
    done
    #not valid
    _err "Error read records of all domains $SL_Ver"
    return 1
  else
    #not valid
    _err "Error. Unsupported version API $SL_Ver"
    return 1
  fi
}

#################################################################
# use: method add_url body
_sl_rest() {
  m=$1
  ep="$2"
  data="$3"

  _token=$(_get_auth_token)
  #_debug "$_token"
  if [ -z "$_token" ]; then
    _err "BAD key or token $ep"
    return 1
  fi
  if [ "$SL_Ver" = v2 ]; then
    _h1_name="X-Auth-Token"
  else
    _h1_name='X-Token'
  fi
  export _H1="${_h1_name}: ${_token}"
  export _H2="Content-Type: application/json"
  _debug3 "Full URI: " "$SL_Api/${SL_Ver}${ep}"
  _debug3 "_H1:" "$_H1"
  _debug3 "_H2:" "$_H2"

  if [ "$m" != "GET" ]; then
    _debug data "$data"
    response="$(_post "$data" "$SL_Api/${SL_Ver}${ep}" "" "$m")"
  else
    response="$(_get "$SL_Api/${SL_Ver}${ep}")"
  fi

  if [ "$?" != "0" ]; then
    _err "error $ep"
    return 1
  fi
  _debug2 response "$response"
  return 0
}

#################################################################3
# use:
_get_auth_token() {
  if [ "$SL_Ver" = 'v1' ]; then
    # token for v1
    _debug "Token v1"
    _token_keystone=$SL_Key
  elif [ "$SL_Ver" = 'v2' ]; then
    # token for v2. Get a token for calling the API
    _debug "Keystone Token v2"
    token_v2=$(_readaccountconf_mutable SL_Token_V2)
    if [ -n "$token_v2" ]; then
      # The structure with the token was considered. Let's check its validity
      # field 1 - SL_Login_Name
      # field 2 - token keystone
      # field 3 - SL_Login_ID
      # field 4 - SL_Project_Name
      # field 5 - Receipt time
      # separator - ';'
      _login_name=$(_getfield "$token_v2" 1 "$_sl_sep")
      _token_keystone=$(_getfield "$token_v2" 2 "$_sl_sep")
      _project_name=$(_getfield "$token_v2" 4 "$_sl_sep")
      _receipt_time=$(_getfield "$token_v2" 5 "$_sl_sep")
      _login_id=$(_getfield "$token_v2" 3 "$_sl_sep")
      _debug3 _login_name "$_login_name"
      _debug3 _login_id "$_login_id"
      _debug3 _project_name "$_project_name"
      _debug3 _receipt_time "$(date -d @"$_receipt_time" -u)"
      # check the validity of the token for the user and the project and its lifetime
      #_dt_diff_minute=$(( ( $(EPOCHSECONDS)-$_receipt_time )/60 ))
      _dt_diff_minute=$(( ( $(date +%s)-_receipt_time )/60 ))
      _debug3 _dt_diff_minute "$_dt_diff_minute"
      [ "$_dt_diff_minute" -gt "$SL_Expire" ] && unset _token_keystone
      if [ "$_project_name" != "$SL_Project_Name" ] || [ "$_login_name" != "$SL_Login_Name" ] || [ "$_login_id" != "$SL_Login_ID" ]; then
        unset _token_keystone
      fi
      _debug "Get exists token"
    fi
    if [ -z "$_token_keystone" ]; then
      # the previous token is incorrect or was not received, get a new one
      _debug "Update (get new) token"
      _data_auth="{\"auth\":{\"identity\":{\"methods\":[\"password\"],\"password\":{\"user\":{\"name\":\"${SL_Login_Name}\",\"domain\":{\"name\":\"${SL_Login_ID}\"},\"password\":\"${SL_Pswd}\"}}},\"scope\":{\"project\":{\"name\":\"${SL_Project_Name}\",\"domain\":{\"name\":\"${SL_Login_ID}\"}}}}}"
      #_secure_debug2 "_data_auth" "$_data_auth"
      export _H1="Content-Type: application/json"
      # body  url [needbase64] [POST|PUT|DELETE] [ContentType]
      _result=$(_post "$_data_auth" "$auth_uri")
      _token_keystone=$(cat "$HTTP_HEADER" | grep 'x-subject-token' | sed -nE "s/[[:space:]]*x-subject-token:[[:space:]]*([[:print:]]*)(\r*)/\1/p")
      #echo $_token_keystone > /root/123456.qwe
      #_dt_curr=$EPOCHSECONDS
      _dt_curr=$(date +%s)
      SL_Token_V2="${SL_Login_Name}${_sl_sep}${_token_keystone}${_sl_sep}${SL_Login_ID}${_sl_sep}${SL_Project_Name}${_sl_sep}${_dt_curr}"
      _saveaccountconf_mutable SL_Token_V2 "$SL_Token_V2"
    fi
  else
    # token set empty for unsupported version API
    _token_keystone=""
  fi
  printf -- "%s" "$_token_keystone"
}

#################################################################
# use: [non_save]
_sl_init_vars() {
  _non_save="${1}"
 _debug2 _non_save "$_non_save"

  _debug "First init variables"
  # version API
  SL_Ver="${SL_Ver:-$(_readaccountconf_mutable SL_Ver)}"
  if [ -z "$SL_Ver" ]; then
    SL_Ver=""
    _err "You don't specify selectel.ru API version yet."
    _err "Please specify you API version and try again."
    return 1
  fi
  _debug2 SL_Ver "$SL_Ver"

  if [ "$SL_Ver" = "v1" ]; then
    # token
    SL_Key="${SL_Key:-$(_readaccountconf_mutable SL_Key)}"

    if [ -z "$SL_Key" ]; then
      SL_Key=""
      _err "You don't specify selectel.ru api key yet."
      _err "Please create you key and try again."
      return 1
    fi
    #save the api key to the account conf file.
    if [ -z "$_non_save" ]; then
      _saveaccountconf_mutable SL_Key "$SL_Key"
    fi
  elif [ "$SL_Ver" = "v2" ]; then
    # time expire token
    SL_Expire="${SL_Expire:-$(_readaccountconf_mutable SL_Expire)}"
    if [ -z "$SL_Expire" ]; then
      SL_Expire=1400 # 23h 20 min
    fi
    if [ -z "$_non_save" ]; then
      _saveaccountconf_mutable SL_Expire "$SL_Expire"
    fi
    # login service user
    SL_Login_Name="${SL_Login_Name:-$(_readaccountconf_mutable SL_Login_Name)}"
    if [ -z "$SL_Login_Name" ]; then
      SL_Login_Name=''
      _err "You did not specify the selectel.ru API service user name."
      _err "Please provide a service user name and try again."
      return 1
    fi
    if [ -z "$_non_save" ]; then
      _saveaccountconf_mutable SL_Login_Name "$SL_Login_Name"
    fi
    # user ID
    SL_Login_ID="${SL_Login_ID:-$(_readaccountconf_mutable SL_Login_ID)}"
    if [ -z "$SL_Login_ID" ]; then
      SL_Login_ID=''
      _err "You did not specify the selectel.ru API user ID."
      _err "Please provide a user ID and try again."
      return 1
    fi
    if [ -z "$_non_save" ]; then
      _saveaccountconf_mutable SL_Login_ID "$SL_Login_ID"
    fi
    # project name
    SL_Project_Name="${SL_Project_Name:-$(_readaccountconf_mutable SL_Project_Name)}"
    if [ -z "$SL_Project_Name" ]; then
      SL_Project_Name=''
      _err "You did not specify the project name."
      _err "Please provide a project name and try again."
      return 1
    fi
    if [ -z "$_non_save" ]; then
      _saveaccountconf_mutable SL_Project_Name "$SL_Project_Name"
    fi
    # service user password
    SL_Pswd="${SL_Pswd:-$(_readaccountconf_mutable SL_Pswd)}"
    if [ -z "$SL_Pswd" ]; then
      SL_Pswd=''
      _err "You did not specify the service user password."
      _err "Please provide a service user password and try again."
      return 1
    fi
    if [ -z "$_non_save" ]; then
      _saveaccountconf_mutable SL_Pswd "$SL_Pswd" "12345678"
    fi
  else
    SL_Ver=""
    _err "You also specified the wrong version of the selectel.ru API."
    _err "Please provide the correct API version and try again."
    return 1
  fi

  if [ -z "$_non_save" ]; then
    _saveaccountconf_mutable SL_Ver "$SL_Ver"
  fi

  return 0
}
