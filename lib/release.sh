echo " starting the release.sh script "
#echo  "see environment variables below :" 
#env 
echo "This is the application HOME directory: ${PWD}"
echo "The BlueSecure dashboard can be found in the follow URL:"   
echo `cat ${DEFENDER_HOME}/dash ${DEFENDER_HOME}/sid `

source ${DEFENDER_HOME}/enforcer.sh
# need to be run at least once 
set_a_side_original_node_modules ${DEFENDER_HOME}/..


${DEFENDER_HOME}/protect.sh ${DEFENDER_HOME} "runonce"
if [ -f ${DEFENDER_HOME}/action.txt ] ; then 
    echo `cat ${DEFENDER_HOME}/action.txt`
	enforce `cat ${DEFENDER_HOME}/action.txt`
fi 	
echo " running --> npm start"

#ugly soluation for now - need to combine both CF and docker under one script.
if  [ "${DEFENDER_HOME}e" = "/app/.defendere" ] ; then 
	${DEFENDER_HOME}/protect.sh ${DEFENDER_HOME} ${DEFENDER_HOME} &
fi 

npm start
