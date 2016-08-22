refresh_exisiting_node_modules() {
  local build_dir=${1:-}

  set_a_side_original_node_modules $build_dir
  
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
  npm install || true
  npm shrinkwrap || true
  echo "deleting old node_modules directory..."
}

set_a_side_original_node_modules() {
  local build_dir=${1:-}
  # create original files in the app directory , so we can revert back to the 
  # original application, if the user ask for it. this is done ONLY ONCE at startup.
  if [  \( ! -e $build_dir/node_modules.orig \) -a \( -e $build_dir/node_modules \) ] ; then 
	cp -r $build_dir/node_modules $build_dir/node_modules.orig || true
	echo "set a side original node_modules directory..."
  fi
  if [ ! -e $build_dir/npm-shrinkwrap.json.orig -a -e $build_dir/npm-shrinkwrap.json  ] ; then 
	cp $build_dir/npm-shrinkwrap.json $build_dir/npm-shrinkwrap.json.orig || true
    echo "set a side original npm-shrinkwrap.json..."
  fi
  if [ ! -e $build_dir/package.json.orig -a -e $build_dir/package.json ] ; then 
	cp $build_dir/package.json $build_dir/package.json.orig || true
    echo "set a side original package.json..."
  fi
  
}

revert_to_original(){
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


revert_to_old(){
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