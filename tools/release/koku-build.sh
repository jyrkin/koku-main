#!/bin/bash
#
# KoKu release management script.
#
# Ixonos / aspluma
#

modules='koku-processes koku-services koku-ui'
vcs_dir_type=tag
svn_repo_base=https://ext-svn.ixonos

function usage() {
  echo "usage: koku-build.sh -r release_version -c {mark_release | build_packages} -t {portal_epp | epp_epp} [-e]"
  exit 1
}

function fail_if_vcs_dir_exists() {
  local mods="$1"
  local vcs_type="$2"
  local vcs_dir="$3"
  for m in $mods; do
    mod_tags=$(svn ls $svn_repo_base/kohtikumppanuutta/$m/$vcs_dir)
    rv=$?
    [ $rv -ne 0 ] && echo "failed to get $vcs_dir for $m, exiting" && exit 1
    echo "$mod_tags" | grep -q "^$koku_rel_v/$"
    rv=$?
    [ $rv -eq 0 ] && echo "$vcs_type $koku_rel_v already exists for module '$m', exiting" && exit 1
  done
}

function get_vcs_dir_by_type() {
  case "$1" in
  tag)
	res="tags"
	;;
  branch)
	res="branches"
	;;
  *) echo "unknown vcs dir type"
	exit 1
	;;
  esac
}

function mark_release() {
  local mods="$1"
  local vcs_type="$2"
  local vcs_dir="$3"
  for m in $mods; do
    svn copy $svn_repo_base/kohtikumppanuutta/$m/trunk \
           $svn_repo_base/kohtikumppanuutta/$m/$vcs_dir/$koku_rel_v \
        -m "KoKu / $m: $koku_rel_v $vcs_type."
  done
}

function prepare_loora_packages() {
	case $deploy_target in
	  portal_epp)
		echo "WARNING: Removing EPP spesific notations"
		rm lok/src/main/webapp/WEB-INF/jboss-web.xml
		rm kks/src/main/webapp/WEB-INF/jboss-web.xml
		sed -i'' 's/\/portlet" prefix=/\/portlet_2_0" prefix=/' {kks,lok}/src/main/webapp/WEB-INF/jsp/*/imports.jsp
		sed -i'' '/EPP only: start/,/EPP only: end/d' */src/main/webapp/WEB-INF/web.xml arcusys-portlet/*/src/main/webapp/WEB-INF/web.xml
		;;
	  *) echo "No Loora preparation needed"
	  ;;
	esac
}

function build_packages() {
  local vcs_dir="$1"

  # create release dirs
  mkdir release-$koku_rel_v
  cd "release-$koku_rel_v"
  mkdir kunpo loora eap
  EAP_DIR=$PWD/eap
  KUNPO_DIR=$PWD/kunpo
  LOORA_DIR=$PWD/loora
  cd ..

  # do a full, fresh checkout
  for m in $modules; do
    echo "info: processing $m"
    cd $m

	# verify that the version tag exists
	st_out=$(git tag -l $koku_rel_v)
	if [ $? -ne 0 -o "x$st_out" == "x" ]; then
	  echo "error: version not tagged: $koku_rel_v, aborting"
	  exit 1
	fi

    echo "info: switching $m to branch $koku_rel_v"
    git checkout $koku_rel_v

	# verify that checked out working is clean
	st_out=$(git status --porcelain)
	rv=$?
	if [ $rv -ne 0 -o "$st_out" ]; then
	  echo "error: Working copy not clean, exiting."
	  echo "info: use 'git clean' to clean it"
	  exit 1
	else
	  echo "info: $m is clean"
	fi

	# set Git revision
	rev=$(git describe)
	[ $? -ne 0 ] && echo "error: failed to get Git revision for $m, aborting" && exit 1
	varname=rev_$m
	varname=${varname//-/_}
	eval "$varname=$rev"

    cd ..
  done
  
  # build
  # build: services
  pushd koku-services
  mvn -Dkoku.build.version=$koku_rel_v -Dkoku.build.vcs-version=$rev_koku_services clean install
  cp */target/*.ear intalio/target/palvelut-web-service-*.jar $EAP_DIR
  popd

  # build: ui
  # build/ui: kunpo packages
  pushd koku-ui
  mvn -Dkoku.build.version=$koku_rel_v -Dkoku.build.vcs-version=$rev_koku_ui clean install
  cp kks/target/kks-portlet-*.war pyh/target/pyh-portlet-*.war $KUNPO_DIR
  cp arcusys-portlet/koku-palvelut-portlet/target/palvelut-portlet.war arcusys-portlet/koku-message-portlet/target/koku-message-portlet.war \
    arcusys-portlet/koku-taskmanager-portlet/target/koku-taskmanager-portlet.war \
    arcusys-portlet/koku-navi-portlet/target/koku-navi-portlet.war $KUNPO_DIR

  # build/ui: loora packages
  
  prepare_loora_packages
  mvn -Dkoku.build.version=$koku_rel_v -Dkoku.build.vcs-version=$rev_koku_ui clean install
  cp kks/target/kks-portlet-*.war lok/target/lok-portlet-*.war $LOORA_DIR
  cp arcusys-portlet/koku-palvelut-portlet/target/palvelut-portlet.war arcusys-portlet/koku-message-portlet/target/koku-message-portlet.war \
    arcusys-portlet/koku-taskmanager-portlet/target/koku-taskmanager-portlet.war \
    arcusys-portlet/koku-navi-portlet/target/koku-navi-portlet.war $LOORA_DIR
  popd
}

while getopts "r:c:t:e" o; do
  case $o in
    r) koku_rel_v=$OPTARG
	  ;;
    c) build_command=$OPTARG
	  ;;
    e) is_ext_user=1
	  ;;
	t) deploy_target=$OPTARG
	  ;;  
    *) echo "?"
	  exit 1
	  ;;
  esac
done

if [ "x" = "x$koku_rel_v" -o "x" = "x$build_command" -o "x" = "x$deploy_target" ]; then
  usage
fi

# set runtime variables
if [ "x" = "x$is_ext_user" ]; then
  svn_repo_base=$svn_repo_base.local
else
  svn_repo_base=$svn_repo_base.com
fi

get_vcs_dir_by_type $vcs_dir_type
vcs_dir=$res

case $build_command in
  mark_release)
  	echo "ERROR: mark_release not yet updated for Git"
  	exit 1
	fail_if_vcs_dir_exists "$modules" $vcs_dir_type $vcs_dir
	echo "$vcs_dir_type $koku_rel_v doesn't exist. creating ${vcs_dir_type}"
	mark_release "$modules" $vcs_dir_type $vcs_dir
	;;
  build_packages)
	build_packages $vcs_dir
	;;
  *) echo "unknown build command"
	exit 1
	;;
esac


exit 0

