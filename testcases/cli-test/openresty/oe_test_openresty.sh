source "../common/common_lib.sh"


function pre_test() {
    LOG_INFO "install openresty and test dep"
    DNF_INSTALL "openresty curl pgrep"
    LOG_INFO "create testdir..."
    testdir=$(mktemp -d)
    test -d ${testdir}
    CHECK_RESULT $? 0 0 "exec mktemp failed"
    cd testdir;
    mkdir logs/ conf/
    cp -f common/nginx.conf ${testdir}/conf
    LOG_INFO " at $testdir."
}
function run_test() {
    LOG_INFO "Start testing..."
    cd ${testdir} && /usr/local/openresty/nginx/sbin/nginx -p `pwd`/ -c conf/nginx.conf
    CHECK_RESULT $? 0 0 "openresty nginx stated"
    curl http://localhost:9000/ | grep -cE "Hello, World!"
    CHECK_RESULT $? 0 0 "nginx alive!"
    LOG_INFO "Finish test!"
}

function post_test(){
    LOG_INFO "post_test"
    LOG_INFO "kill openresty's nginx"
    kill $(pgrep -f ${testdir})
    LOG_INFO "remove testdir"
    rm -rf ${testdir}
    LOG_INFO "remove test dep"
    DNF_REMOVE
    LOG_INFO "post_test fine."
}

main $@
