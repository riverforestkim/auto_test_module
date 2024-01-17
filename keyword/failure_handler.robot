*** Settings ***
Library      String


*** Keywords ***
Fail With Log
    [Arguments]    ${FAIL_MESSAGE}    ${LOG}    ${LOG_LEVEL}
    Log    ${LOG}    ${LOG_LEVEL}
    fail    ${FAIL_MESSAGE}
