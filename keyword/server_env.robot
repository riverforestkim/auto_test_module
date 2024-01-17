*** Settings ***
Library      SSHLibrary
Library      String

*** Keywords ***
TMS VERISON 확인
    ${INSTALL_PATH}=        Execute Command       grep -r -i TMS_INSTALL_PATH= /root/.bash_tmsplus40 | tail -1 | cut -f 2 -d '='
    Write    cd ${INSTALL_PATH}; ./.tms -v
    ${TMS_VERSION}=    Read    delay=1s
    Log to console     ${TMS_VERSION}
    Run Keyword And Continue On Failure     Should Be True    """${TMS_VERSION}"""!="""${EMPTY}"""

TMS INSTALL TYPE 확인
    ${INSTALL_PATH}=        Execute Command       grep -r -i TMS_INSTALL_PATH= /root/.bash_tmsplus40 | tail -1 | cut -f 2 -d '='
    ${INSTALL_TYPE_FLAG}=           Execute Command     file ${INSTALL_PATH}/APP/CONFIG/config.cfg | awk '{print $5}'| grep -c slave
    
    IF  ${INSTALL_TYPE_FLAG}==0
        Log To Console    "INSTALL TYPE = MASTER"
        ${INSTALL_TYPE}=     Set Variable     MASTER
    ELSE
        Log To Console    "INSTALL TYPE = SLAVE"
        ${INSTALL_TYPE}=     Set Variable     SLAVE
    END
    
    Set Suite Variable    ${INSTALL_TYPE}

HDD & RAID 상태 확인
    ${HDD_LIST}=    Execute Command    df -h | awk '{print $6}' | sed -n '2,\$p'
    @{HDD_LIST}=    Split String       ${HDD_LIST}    \n

    FOR    ${RAID}    IN     @{HDD_LIST}
        ${HDD_USAGE}=    Execute Command    df -h ${RAID} | awk '{print $5}' | sed -n '2,\$p'
        ${HDD_USAGE}=    Replace String     ${HDD_USAGE}    %    ${EMPTY}
        Run Keyword And Continue On Failure     Should Be True   ${HDD_USAGE}<90
    END

CPU 상태 확인
    ${CPU_USAGE}=    Execute Command    top -b -n 1 | grep -Po '[0-9.]+ id' | awk '{print 100-$1}'
    Run Keyword And Continue On Failure     Should Be True   ${CPU_USAGE}<90

MEM 상태 확인
    ${MEM_TOTAL}=    Execute Command    free | grep ^Mem | awk '{print $2}'
    ${MEM_USAGE}=    Execute Command    free | grep ^Mem | awk '{print $3}'
    ${MEM_USAGE_PERCENT}=    Evaluate    ${MEM_USAGE}/${MEM_TOTAL} * 100
    Run Keyword And Continue On Failure     Should Be True   ${MEM_USAGE_PERCENT}<90

DISK 상태 확인
    # ${DISK_LIST}=    Execute Command    df -h | awk '{print $1}' | grep /
    # @{DISK_LIST}=    Split String       ${DISK_LIST}    \n

    #SKIP If 
    # FOR    ${DISK}    IN     @{DISK_LIST}
    #     ${HEALTH_CHECK_RESULT}=    Execute Command    smartctl -H ${DISK} | grep -E "SMART Health Status: OK|test result: PASSED" | wc -l
    #     Run Keyword And Continue On Failure     Should Be True   ${HEALTH_CHECK_RESULT}==1
    # END
    
    ${DISK_PARTITION_COUNT}=    Execute Command    df -h | grep -c -E "backup|home1|data" 

    SKIP IF    ${DISK_PARTITION_COUNT}<3
    Run Keyword And Continue On Failure     Should Be True   ${DISK_PARTITION_COUNT}>=3

데이터 수집 확인
    Write    date "+%Y%m%d"
    ${DATE}=    Read Until    expected=\n
    Write    mongo --port 23011
    Read     delay=0.5s
    Write    use db_${DATE}
    Read     delay=0.5s
    Write    db.log_detect_event.count()
    ${EVENT_COUNT}=    Read Until    expected=\n
    ${EVENT_COUNT}=    Convert To Integer    ${EVENT_COUNT}
    Run Keyword And Continue On Failure     Should Be True   ${EVENT_COUNT}>0
    Write    exit
    Read     delay=0.5s

네트워크 세션 연결 확인
    ${8080_ESTABLISHED_SESSION}=    Execute Command    netstat -nap | grep 8080 | grep ESTABLISHED | wc -l
    ${8999_ESTABLISHED_SESSION}=    Execute Command    netstat -nap | grep 8999 | grep ESTABLISHED | wc -l

    IF  ${8080_ESTABLISHED_SESSION}==0 
        IF  ${8999_ESTABLISHED_SESSION}==0
            Log To Console    "ESTABLISHED sessions do not exist on ports 8080 and 8999."
            Run Keyword And Continue On Failure     Should Be True   0>0
        ELSE
            Run Keyword And Continue On Failure     Should Be True   1>0
        END
    END

코어 파일 발생 확인
    #서버 사양마다 tps_process_monitor가 늦게 돌아서 코어 디렉토리가 생성되지 않는 경우가 발생
    Sleep    60s
    ${INSTALL_PATH}=        Execute Command       grep -r -i TMS_INSTALL_PATH= /root/.bash_tmsplus40 | tail -1 | cut -f 2 -d '='
    ${CORE_DIR_FILE_COUNT}=    Execute Command       cd ${INSTALL_PATH}/APP/CoreDir/; ls | wc -l
    ${CORE_DIR_FILE_COUNT}=    Convert To Integer    ${CORE_DIR_FILE_COUNT}
    ${CORE_FILE_COUNT}=        Execute Command       cd /data/tms-core; ls | wc -l
    ${CORE_FILE_COUNT}=        Convert To Integer    ${CORE_FILE_COUNT}
    ${LOG_RESULT}=             Set Variable          ${INSTALL_PATH}/APP/CoreDir/ = ${CORE_DIR_FILE_COUNT}, /data/tms-core = ${CORE_FILE_COUNT}
    Run keyword if    ${CORE_DIR_FILE_COUNT}==0 and ${CORE_FILE_COUNT}==0    Log     ${LOG_RESULT}    DEBUG    ELSE    Fail With Log    코어 파일이 발생한 것을 확인    ${LOG_RESULT}     DEBUG


