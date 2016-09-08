echo " starting the release.sh script "
#echo  "see environment variables below :" 
#env 
echo "This is the application HOME directory: ${PWD}"
echo "The BlueSecure dashboard can be found in the follow URL:"   
echo `cat ${DEFENDER_HOME}/dash ${DEFENDER_HOME}/sid `

${DEFENDER_HOME}/protect.sh ${DEFENDER_HOME} "runonce"
if [ -f ${DEFENDER_HOME}/action.txt ] ; then 
	source ${DEFENDER_HOME}/enforcer.sh
	enforce `cat ${DEFENDER_HOME}/action.txt`
fi 	

npm start
