
echo "running defender ..."


while [[ $# > 0 ]]
do
  key="$1"

  case $key in
    -c|--clean)
	if [ -f ${DEFENDER_HOME}/sid ]; then
		rm ${DEFENDER_HOME}/sid || true
	fi		
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 32 > ${DEFENDER_HOME}/sid
    if [ ! -f ${DEFENDER_HOME}/url ]; then
       echo -n "https://bluesecure.mybluemix.net" > ${DEFENDER_HOME}/url
    fi
    if [ ! -f ${DEFENDER_HOME}/dash ]; then
       echo -n "https://bluesecuredashboard.mybluemix.net?channel=" > ${DEFENDER_HOME}/dash
    fi
    ;;
    *)
       # unknown option
    ;;
  esac
  shift # past argument or value
done


sid=`cat ${DEFENDER_HOME}/sid`
url=`cat ${DEFENDER_HOME}/url`
dash=`cat ${DEFENDER_HOME}/dash`
echo "Defender URL         : " $url
echo "Application Identity : " $sid
echo "Application Dashboard: " ${dash}${sid}

