*** Settings ***
Library      SSHLibrary

*** Keywords ***
#SSH
SSH 접속 
    [Arguments]         ${IP}    ${PORT}      ${ID}      ${PWD}
    Open Connection     ${IP}    port=${PORT}
    Login               ${ID}    ${PWD}
    # 타임아웃 일단 5분 설정
    set client configuration  timeout=300s

SSH연결 종료            
    Close Connection
