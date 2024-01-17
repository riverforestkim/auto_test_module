*** Settings ***
Library      SSHLibrary
Library      String

*** Keywords ***

#종속성..
NET-SNMP 체크
    [Arguments]                       ${PKG_NAME}
    ${PKG_DIR}=                       Get Substring      ${PKG_NAME}    0       -7
    ${VERSION}=                       Set Variable       5.9.1 
    ${VERSION_RESULT}=                Execute Command    snmpd -v | grep ${VERSION} | wc -l
    ${GO_PKG_PATH_CMD}=               Set Variable       cd ${설치서버['PKG_UPLOAD_PATH']}/${PKG_DIR}/trace-log
    #설치 프로세스 진행 확인                           
    ${TMS_INSTALL_LOG}=               Execute Command    ${GO_PKG_PATH_CMD}; ls -tr *.log | tail -n1
    ${CHECK_SNMP_INSTALL_PROCESS}=    Execute Command    ${GO_PKG_PATH_CMD}; grep "install snmp, version = ${VERSION}" ${TMS_INSTALL_LOG} | wc -l
    Run Keyword And Continue On Failure     Should not be equal    ${CHECK_SNMP_INSTALL_PROCESS}    0   
    #버전 확인
    Run Keyword And Continue On Failure     Should be equal    ${VERSION_RESULT}    1    

