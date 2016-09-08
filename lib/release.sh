echo " starting the release.sh script "
echo  "see environment variables below :" 
env 
echo "This is the application HOME directory: ${PWD}"
echo "The BlueSecure dashboard can be found in the follow URL:" 
echo `cat ${DEFENDER_HOME}/dash ${DEFENDER_HOME}/sid `

${DEFENDER_HOME}/protect.sh ${DEFENDER_HOME} "runonce"
source ${DEFENDER_HOME}/enforcer.sh
enforce `cat action.txt`

npm start
