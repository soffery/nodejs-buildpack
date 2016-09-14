#/bin/bash

reinstall_packages() {
  local build_dir=${1:-}
  
  cd $build_dir || true
  npm install || true
  npm shrinkwrap || true
  echo "reinstalled node_modules directory..."
}

backup_packages() {
  if  [ "${CONTAINER_TYPE}" = "cf" ] ; then 
	return;
  fi	

  local build_dir=${1:-}
 
  # last back up - if the user need to go back one step
  if [ -e $build_dir/node_modules  ] ; then 
	mv $build_dir/node_modules $build_dir/node_modules.old || true
  fi
  
  # if there is a user supply npm-shrinkwrap.json ,this thing will override it 
  if [ -e $build_dir/npm-shrinkwrap.json  ] ; then 
	mv $build_dir/npm-shrinkwrap.json  $build_dir/npm-shrinkwrap.json.old || true
  fi
  
  if [ -e $build_dir/package.json  ] ; then 
	cp $build_dir/package.json  $build_dir/package.json.old || true
  fi	
  cd $build_dir || true
  echo "backup_packages node_modules directory..."
}

set_a_side_original_node_modules() {
  if  [ "${CONTAINER_TYPE}" = "cf" ] ; then 
	return;
  fi	
  
  local build_dir=${1:-}
  
  # create original files in the app directory , so we can revert back to the 
  # original application, if the user ask for it. this is done ONLY ONCE at startup.
  if [  \( ! -e $build_dir/node_modules.orig \) -a \( -e $build_dir/node_modules \) ] ; then 
	cp -r $build_dir/node_modules $build_dir/node_modules.orig || true
	echo "set a side original node_modules directory..."
  fi
  # NOTE this is optional - the file way exist or not.
  if [ ! -e $build_dir/npm-shrinkwrap.json.orig -a -e $build_dir/npm-shrinkwrap.json  ] ; then 
	cp $build_dir/npm-shrinkwrap.json $build_dir/npm-shrinkwrap.json.orig || true
    echo "set a side original npm-shrinkwrap.json..."
  fi
  if [ ! -e $build_dir/package.json.orig -a -e $build_dir/package.json ] ; then 
	cp $build_dir/package.json $build_dir/package.json.orig || true
    echo "set a side original package.json..."
  fi
  
}

undo_all_updates(){
  if  [ "${CONTAINER_TYPE}" = "cf" ] ; then 
	return;
  fi	
  
  local build_dir=${1:-}
  # move to original files in the app directory ,reverting back to the 
  # as in the original application, if the user ask for it.
  if [ -e $build_dir/node_modules.orig ] ; then 
	cp $build_dir/node_modules.orig $build_dir/node_modules || true
  fi
  if [ -e $build_dir/npm-shrinkwrap.json.orig ] ; then 
	cp $build_dir/npm-shrinkwrap.json.orig $build_dir/npm-shrinkwrap.json || true
  fi
  if [ -e $build_dir/package.json.orig ] ; then 
	cp $build_dir/package.json.orig $build_dir/package.json || true
  fi
  
  echo "moved back to original application files  ..."

}

undo_last_update(){
  if  [ "${CONTAINER_TYPE}" = "cf" ] ; then 
	return;
  fi	
  local build_dir=${1:-}
  # move to original files in the app directory ,reverting back to the 
  # as in the original application, if the user ask for it.
  if [ -e $build_dir/node_modules.old ] ; then 
	cp $build_dir/node_modules.old $build_dir/node_modules || true
  fi
  if [ -e $build_dir/npm-shrinkwrap.json.old ] ; then 
	cp $build_dir/npm-shrinkwrap.json.old $build_dir/npm-shrinkwrap.json || true
  fi
  if [ -e $build_dir/package.json.old ] ; then 
	cp $build_dir/package.json.old $build_dir/package.json || true
  fi
  
  echo "moved one step back ..."

}

package_json_update(){
	#change the json file to "^{Version}" , where {Version} is what found in the "npm-shrinkwrap.json" file.
	local build_dir=${1:-}
	cd $build_dir
	if [ ! -e $build_dir/npm-shrinkwrap.json ] ; then 
	    npm shrinkwrap
		if [ $? != 0 ]; then 
			echo "Failed to run \"npm shrinkwrap\". please check your application package.json!"
			return ;
		fi
		# try to create the file if it does not exist 
		if [ ! -e $build_dir/npm-shrinkwrap.json ] ; then 
			echo "could not create the npm-shrinkwrap.json ..."
			return;
		fi 
	fi 
 	if [ ! -e $build_dir/package.json ] ; then 
		echo "please check your application for package.json file. It is missing from the build!"
		return;
	fi 
 
	# take from the package.json file the list of pakages that need to be updates at production run 
	# NOTE: what about developmet stage ? 
	export DEP_PKG_LIST=`jq  '.dependencies | to_entries | .[].key  ' $build_dir/package.json | sed 's/"//g'`


	for dep_pkg in $DEP_PKG_LIST; do 
		# for each package get the current version as seen by the "npm shrinkwrap" command
		# add for it the general mark "^" which in npm languge allow some freedom for an upgrade of the package
		#local dep_pkg_version=`jq '.dependencies[] ' $build_dir/npm-shrinkwrap.json | grep -B 2 ${dep_pkg}@  | grep version | awk '{ print $2 }' | sed 's/,// ; s/^"/"^/'`
		local dep_pkg_version=`jq '.dependencies.${dep_pkg}.version ' $build_dir/npm-shrinkwrap.json | sed 's/"/"^/'`
		#update the package.json to allowed freedom. 
		jq ".dependencies.${dep_pkg} = $dep_pkg_version " $build_dir/package.json > $build_dir/package.json.new
		mv $build_dir/package.json.new $build_dir/package.json
	done 

    echo " Changed the package.json " 
		
}

enforce() {
    # enforcer start 
	local build_dir=$APP_DIR
	cd $build_dir
	# check that the file exist if not return.
	if [ ! -e ${DEFENDER_HOME}/action.txt ] ;  then
		return;
	fi	

	# NOTE : we can handle a list of actions here - now only handling one action ,only.
	local action=`cat ${DEFENDER_HOME}/action.txt| head -n 1`

	# if action is empty file - rturn;
	if [ -z "${action}" ] ; then 
	   return ; 
	fi 
	echo "Updating the application with $action " 
	
	# need to be run at least once 
    set_a_side_original_node_modules $build_dir
	
	case "${action}" in
        reinstall_packages)
		    backup_packages $build_dir
            reinstall_packages $build_dir
            ;;
         
        update_packages)
		    backup_packages $build_dir
            package_json_update $build_dir
			reinstall_packages $build_dir
            ;;
         
        undo_all_updates)
			undo_all_updates $build_dir
            ;;
        undo_last_update)
			undo_last_update $build_dir
			;;
         
        *)
            echo $"Usage: $0 {reinstall_packages|update_packages|undo_all_updates|undo_last_update|}"
			#env 
            exit 0
 
	esac

}