MakeParamsString(sParams*)
{
    for index, param in sParams
        sAllParams .= """" param """ " ;обрамляем каждый параметр в кавычки
    return SubStr(sAllParams, 1, -1) ;trim last useless space
}
