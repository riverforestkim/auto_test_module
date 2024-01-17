*** Settings ***
Library      SSHLibrary
Library      String
Resource     failure_handler.robot 

*** Keywords ***
python2 - 모듈 테스트
    [Arguments]         ${MODULE_NAME}
    ${PYTHON}=             Set Variable        python
    ${CMD}=             Set Variable        ${PYTHON} -m pip freeze | grep ${MODULE_NAME}  
    ${RESULT}=    Execute Command     ${CMD}\n
    Run keyword if   ${MODULE_NAME} in """${RESULT}"""     Log     ${RESULT}    DEBUG    ELSE    Fail With Log    ${MODULE_NAME} 비정상 확인    ${LOG_RESULT}     DEBUG



