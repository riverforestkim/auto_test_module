*** Settings ***
Variables    ../config.yml
Library      SSHLibrary
Library      String
Resource     failure_handler.robot 

*** Keywords ***
#프로세스 체크 - 공통 테스트케이스

데몬 체크 
    [Arguments]            ${DAEMONLIST}
    FOR    ${DAEMON}    IN     @{DAEMONLIST}        
        ${RESULT}=             Execute Command     ps -ef | grep -v grep | grep -c "${DAEMON}"
        ${LOG_RESULT}=         Execute Command     ps -ef | grep -v grep | grep "${DAEMON}"
        #Run Keyword And Continue On Failure     Should be equal    ${RESULT}    1    
        Run keyword if    ${RESULT}==1     Log     ${LOG_RESULT}    DEBUG    ELSE    Fail With Log    ${DAEMON} 비정상 확인    ${LOG_RESULT}     DEBUG
    END

MongoDB 데몬 체크
    IF  "${INSTALL_TYPE}"=="MASTER"
        데몬 체크    DAEMONLIST=${데몬리스트['MongoDB_MASTER']}
    ELSE
        데몬 체크    DAEMONLIST=${데몬리스트['MongoDB_SLAVE']}
    END

아파치 체크
    # 통합 체크 테스트케이스
    # [Documentation]    설치 후, httpd 프로세스가 5개 이상 기동되는지 확인
    # ...                lsof를 통해 apache 프로세스의 경로를 확인, /home1/apache 경로로 되어있는지 확인
    # ...                libapr-1 프로세스가 /home1/apache 경로의 모듈을 참조하는지 확인
    # ...                8500 포트 listen 상태로 유지되는지 확인
    IF  "${INSTALL_TYPE}"=="MASTER"
        아파치 - 기본 프로세스 체크

        아파치 - 프로세스 경로 확인

        아파치 - http 응답 확인

        아파치 - libapr 프로세스 /home1/apache 경로 모듈 참조 확인

        아파치 - 8500 포트 listen 상태 유지 확인

        아파치 - PID 변경 확인
    ELSE
        Log To Console    SLAVE - 아파치 테스트 생략
    END

############### 아파치 기능 ##################
아파치 - 기본 프로세스 체크
    #기본 프로세스 체크(root)
    ${RESULT}=         Execute Command     ps -ef | grep httpd | grep -v grep | grep -c root
    ${LOG_RESULT}=         Execute Command     ps -ef | grep httpd | grep -v grep | grep root
    Run keyword if    ${RESULT}==1     Log     ${LOG_RESULT}    DEBUG    ELSE    Fail With Log    프로세스 개수(root) 비정상 확인    ${LOG_RESULT}     DEBUG

    #기본 프로세스 체크(apache)
    ${RESULT}=         Execute Command     ps -ef | grep httpd | grep -v grep | grep -v root | grep -c apache
    ${LOG_RESULT}=         Execute Command     ps -ef | grep httpd | grep -v grep | grep -v root | grep apache
    Run keyword if    ${RESULT}==4     Log     ${LOG_RESULT}    DEBUG    ELSE    Fail With Log    프로세스 개수(apache) 비정상 확인    ${LOG_RESULT}     DEBUG

    #defunct 체크
    ${RESULT}=         Execute Command     ps -ef | grep httpd | grep -v grep | grep -c defunct
    ${LOG_RESULT}=         Execute Command     ps -ef | grep httpd | grep -v grep | grep defunct
    Run keyword if    ${RESULT}==0     Log     ${LOG_RESULT}    DEBUG    ELSE    Fail With Log    프로세스 개수(defunct) 비정상 확인    ${LOG_RESULT}     DEBUG

아파치 - 프로세스 경로 확인
    #apache 프로세스 경로 확인
    ${RESULT}=         Execute Command     lsof -c httpd | grep -c /home1/apache/bin
    ${LOG_RESULT}=         Execute Command     lsof -c httpd | grep /home1/apache/bin
    Run keyword if    ${RESULT}==5     Log     ${LOG_RESULT}    DEBUG   ELSE    Fail With Log    apache 프로세스 경로 미확인    ${LOG_RESULT}     DEBUG

아파치 - http 응답 확인
    Write              curl -sk "https://127.0.0.1:8500/sniper.atx?query=info" 
    ${API_RESULT}=    Read Until    expected=query_error_code
    Run keyword if    'SUCCESS' in """${API_RESULT}"""     Log     ${API_RESULT}    DEBUG   ELSE    Fail With Log    curl을 통한 httpd 데몬 응답 테스트에 실패했습니다.     ${API_RESULT}     DEBUG

아파치 - libapr 프로세스 /home1/apache 경로 모듈 참조 확인
    #libapr 프로세스가 /home1/apache 경로의 모듈을 참조하는지 확인
    ${RESULT}=         Execute Command     ldd /home1/apache/bin/httpd | grep -c libapr-1
    ${LOG_RESULT}=         Execute Command     ldd /home1/apache/bin/httpd | grep libapr-1
    Run keyword if    ${RESULT}==1     Log     ${LOG_RESULT}    DEBUG   ELSE    Fail With Log    libapr 프로세스 /home1/apache 모듈을 참조 미확인    ${LOG_RESULT}     DEBUG

아파치 - 8500 포트 listen 상태 유지 확인
    ${RESULT}=         Execute Command     netstat -anp | grep 8500 | grep -c httpd
    ${LOG_RESULT}=         Execute Command     netstat -anp | grep 8500 | grep httpd
    Run keyword if    ${RESULT}!=0     Log     ${LOG_RESULT}    DEBUG    ELSE    Fail With Log    8500 포트 listen 상태로 유지되지 않음    ${LOG_RESULT}     DEBUG

아파치 - PID 변경 확인
    ${PRE_RESULT}=         Execute Command     ps -ef | grep httpd | grep -v grep | grep -v bash | awk '{print $2}'
    ${PRE_LOG_RESULT}=         Execute Command     ps -ef | grep httpd

    #TODO - 10분
    Sleep    300s

    ${RESULT}=         Execute Command     ps -ef | grep httpd | grep -v grep | grep -v bash | awk '{print $2}'
    ${LOG_RESULT}=         Execute Command     ps -ef | grep httpd 
    Run keyword if    """${RESULT}"""=="""${PRE_RESULT}"""    Log     ${LOG_RESULT}    DEBUG    ELSE    Fail With Log    apache의 PID가 변경됨.     현재 \n ${LOG_RESULT} \n 과거 \n ${PRE_LOG_RESULT} \n     DEBUG
 
############### 노드 기능 ##################
노드 체크
    IF  "${INSTALL_TYPE}"=="MASTER"
        노드 - 기본 프로세스 체크
        노드 - 포트 listen 상태 유지 확인
        노드 - 버전 확인
        노드 - 시작 경로
    ELSE
        Log To Console    SLAVE - 노드 테스트 생략
    END

노드 - 기본 프로세스 체크
    #Log To Console     "Checking WebServer(Node)"
    ${RESULT}=         Execute Command     ps -ef | grep -v grep | grep node | grep -c dist/server.js
    ${LOG_RESULT}=         Execute Command     ps -ef | grep -v grep | grep node | grep dist/server.js
    Run keyword if    ${RESULT}==2     Log     ${LOG_RESULT}    DEBUG    ELSE    Fail With Log    노드 서버가 확인되지 않음    ${LOG_RESULT}     DEBUG
