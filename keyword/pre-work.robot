*** Settings ***
Library      String


*** Keywords ***
코어 파일 사이즈 등록
    ${LOG_RESULT}=         Execute Command      ulimit -S -H -c unlimited
    ${RESULT}=         Execute Command      ulimit -c
    #안될 수가 없다..
    Run keyword if     """${RESULT}"""=="""unlimited"""     Log     ${RESULT}    DEBUG   ELSE    Fail With Log    코어 파일 사이즈가 등록되지 않음    ${RESULT}     DEBUG
