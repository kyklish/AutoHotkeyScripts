;CSV format:
;Login,Password
;
;First string must be admin credential
;Second string must be user credential
;В качестве логина админа нужна встроенная учетная запись админа
;Только встроенная учетная запись позволяет запускать приложения от имени админа в AutoHotkey

GetCredentialObjectFromString(sStr) {
    Loop, Parse, sStr, csv
    {
        if (A_Index == 1) {
            sLogin := A_LoopField
        } else
            if (A_Index == 2) {
                sPassword := A_LoopField
            } else
                Break
    }
    return {sLogin: sLogin, sPassword: sPassword}
}

GetCredentials(bAdmin) {
    sFilePath := "Credentials.csv"
    i := 0
    Loop, Read, %sFilePath%
    {
        sStr := Trim(A_LoopReadLine)
        if (SubStr(sStr, 1, 1) = ";" or sStr = "")
            Continue
        i++ ;increment if this A_LoopReadLine is not comment
        if (i == 1) { ;admin credential
            if (bAdmin) {
                obj := GetCredentialObjectFromString(A_LoopReadLine)
                Break
            }
        }
        if (i == 2) { ;user credential
            obj := GetCredentialObjectFromString(A_LoopReadLine)
            Break
        }
    }
    return obj
}

/*
GetCredentials(bAdmin)
{
    ;В качестве логина админа нужна встроенная учетная запись админа
    ;Только встроенная учетная запись позволяет запускать от имени админа в AutoHotkey
    sAdminLogin := "****" ;вместо звездочек написать логины и пароли
    sAdminPassword := "****" ;удалил, чтобы они не светились на GitHub

    sUserLogin := "****"
    sUserPassword := sAdminPassword

    if(bAdmin)
        obj := {sLogin: sAdminLogin, sPassword: sAdminPassword}
    else
        obj := {sLogin: sUserLogin, sPassword: sUserPassword}

    return obj
}
*/
