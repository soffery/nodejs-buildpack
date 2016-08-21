refresh_exisiting_node_modules() {
  local build_dir=${1:-}

  set_a_side_original_node_modules $build_dir
  
  # last back up - if the user need to go back one step
  mv $build_dir/node_modules $build_dir/node_modules.old || true
  # if there is a user supply npm-shrinkwrap.json ,this thing will override it 
  mv $build_dir/npm-shrinkwrap.json  $build_dir/npm-shrinkwrap.json.old || true
  cp $build_dir/package.json  $build_dir/package.json.old || true
  cd $build_dir || true
  npm install || true
  npm shrinkwrap || true
  echo "deleting old node_modules directory..."
}

set_a_side_original_node_modules() {
  local build_dir=${1:-}
  # create original files in the app directory , so we can revert back to the 
  # original application, if the user ask for it.
  if [! -e $build_dir/node_modules.orig ] ; then 
	cp $build_dir/node_modules $build_dir/node_modules.orig || true
	echo "set a side original node_modules directory..."
  fi
  if [! -e $build_dir/npm-shrinkwrap.json ] ; then 
	cp $build_dir/npm-shrinkwrap.json $build_dir/npm-shrinkwrap.json.orig || true
    echo "set a side original npm-shrinkwrap.json..."
  fi
  if [! -e $build_dir/package.json.orig ] ; then 
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