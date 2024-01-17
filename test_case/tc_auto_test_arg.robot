*** Settings ***
Library      String
Resource     ../keyword/process.robot
Resource     ../keyword/ssh_connect.robot
Resource     ../keyword/rpm_install.robot
Resource     ../keyword/server_env.robot 
Resource     ../keyword/pre-work.robot
Resource     ../keyword/python_import_test.robot

*** Tasks ***
#실행 예시 )python -m robot --variable SERVER_IP:10.100.101.11 --variable SSH_PORT:22 --variable SSH_ID:root --variable SSH_PW:test --variable PKG_IP:10.100.101.12 --variable PKG_PORT:22 --variable PKG_ID:root --variable PKG_PW:test tc_auto_test_arg.robot


사전 환경 확인
    SSH 접속        IP=${SERVER_IP}   PORT=${SSH_PORT}     ID=${SSH_ID}    PWD=${SSH_PW}
    SSH연결 종료

MYSQL 데몬 테스트
    SSH 접속        IP=${SERVER_IP}   PORT=${SSH_PORT}     ID=${SSH_ID}    PWD=${SSH_PW}
    SSH연결 종료

SPRING 데몬 테스트
    SSH 접속        IP=${SERVER_IP}   PORT=${SSH_PORT}     ID=${SSH_ID}    PWD=${SSH_PW}
    SSH연결 종료

MongoDB 데몬 테스트
    SSH 접속        IP=${SERVER_IP}   PORT=${SSH_PORT}     ID=${SSH_ID}    PWD=${SSH_PW}
    MongoDB 데몬 체크
    SSH연결 종료

ELASTIC SEARCH 테스트
    SSH 접속        IP=${SERVER_IP}   PORT=${SSH_PORT}     ID=${SSH_ID}    PWD=${SSH_PW}
    SSH연결 종료

아파치 테스트
    SSH 접속        IP=${SERVER_IP}   PORT=${SSH_PORT}     ID=${SSH_ID}    PWD=${SSH_PW}
    아파치 체크
    SSH연결 종료

노드 테스트
    SSH 접속        IP=${SERVER_IP}   PORT=${SSH_PORT}     ID=${SSH_ID}    PWD=${SSH_PW}
    노드 체크
    python2 - 모듈 테스트     MODULE_NAME="ipaddress"
    SSH연결 종료

    
서버 환경 테스트
    SSH 접속                IP=${SERVER_IP}   PORT=${SSH_PORT}     ID=${SSH_ID}    PWD=${SSH_PW}
    HDD & RAID 상태 확인
    CPU 상태 확인
    MEM 상태 확인
    DISK 상태 확인
    코어 파일 발생 확인
    SSH연결 종료 
    
