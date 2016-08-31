
sleep 12

# install node modules for the nodejs files in defender dir 
cd $DEFENDER_HOME
npm install


#look for the "js" file in this directory
export NODE_PATH=$DEFENDER_HOME:$DEFENDER_HOME/node_modules_cpy

export APP_DIR=$DEFENDER_HOME/..

URL=`cat $DEFENDER_HOME/url`
SID=`cat $DEFENDER_HOME/sid`


extract_packages() {

  # write the information in JSON format
  # each line has it output here
  # { "PkgList" : "   --- start the JSON
  echo -n { \"UNIX_PKGS\": { \"packages\" :[ >  $DEFENDER_HOME/distro.json
  # packageVersion,packageVersion ...packageVersion
  dpkg-query -W -f='{"pkg":"${Package}_${Version}"},' | sed 's/,$//' >>  $DEFENDER_HOME/distro.json
  # add aditional packages, written in a file and supply by the buildpack it self 
  #if [  -s $DEFENDER_HOME/importedPackages.csv -a -r $DEFENDER_HOME/importedPackages.csv ]; then
  #  awk -F , '{ if(FNR != 1 && $1 != "" && $2 != "" ) { if(FNR != 2){ printf ","} ;printf( "{\"pkg\":\"%s_%s\"},",$1,$2 )} };' $DEFENDER_HOME/importedPackages.csv  | sed 's/,$//' >>  $DEFENDER_HOME/distro.json
  #fi
  # ", ---- end the packageVersion list  
  echo -n ], >>  $DEFENDER_HOME/distro.json
  # "Codename": "trusty", 
  lsb_release -a 2>&1 |  grep Codename | awk '{printf "\"version\": \"%s\"," ,$2}' >> $DEFENDER_HOME/distro.json
  # "DistributorID": "Ubunto", 
  lsb_release -a 2>&1 | grep "Distributor ID:" | awk '{printf "\"distribution\": \"%s\"",$3}'>> $DEFENDER_HOME/distro.json
  # ", ---- end the Ubonto list and start SID` 
  echo -n },\"sid\":\" >>  $DEFENDER_HOME/distro.json
  cat $DEFENDER_HOME/sid  >>  $DEFENDER_HOME/distro.json
  # ", ---- end the SID and start url`
  echo -n \",\"url\": \">>  $DEFENDER_HOME/distro.json
  cat $DEFENDER_HOME/url >>  $DEFENDER_HOME/distro.json
  echo -n \",>>  $DEFENDER_HOME/distro.json
}

shrinkwrap_json() {
   cd $APP_DIR
   npm shrinkwrap --dev || true
   if [ -f npm-shrinkwrap.json ] ; then 
     echo -n \"shrinkwrap\" :  >>  $DEFENDER_HOME/distro.json
	 cat npm-shrinkwrap.json >>  $DEFENDER_HOME/distro.json
	 echo -n , >>  $DEFENDER_HOME/distro.json
   else 
     echo "Error : could not produce npm-shrinkwrap.json";
	 echo -n \"shrinkwrap\" : {} , >> $DEFENDER_HOME/distro.json
   fi 
}

package_json(){
   cd $APP_DIR
   if [ -f package.json ] ; then 
     echo -n \"packagejson\" :  >>  $DEFENDER_HOME/distro.json
	 cat package.json >>  $DEFENDER_HOME/distro.json
   else 
     echo "Error : could not find  package.json";
	 #  generate an empty one.
	 echo -n \"packagejson\" : {}  >> $DEFENDER_HOME/distro.json
   fi 
}
nodejs_section(){
	echo -n \"nodejs\" : { >>  $DEFENDER_HOME/distro.json
	shrinkwrap_json
	package_json
	echo -n }, >>  $DEFENDER_HOME/distro.json
}
close_json () { 
  # "date": "Wed Jul 27 13:19:17 IDT 2016" }   
  echo -n \"date\": \"`date`\" }>> $DEFENDER_HOME/distro.json
}

extract_node_modules() {
    extract_packages
	nodejs_section
	close_json
	cd $APP_DIR
	#npm ls -json 2>/dev/null | node $DEFENDER_HOME/NodeProtect.js  
	cat $DEFENDER_HOME/distro.json | node $DEFENDER_HOME/NodeProtect.js  
}    


# enforcer user action from blueSecure 
source $DEFENDER_HOME/lib/enforcer.sh
enforce "$APP_DIR" 

i=0
while [ true ]; do
  i=`expr $i + 1`
  
  # extract the node modules every 100 seconds  
  if [ $(( $i % 10)) == 0 ];then  
	extract_node_modules 
	echo extract_node_modules
  fi
  sleep 12;
done;

