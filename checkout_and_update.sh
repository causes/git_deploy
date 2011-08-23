#!/bin/bash
# Example invocation:
#  REPO_DIR=/tmp/git_deploy/repo \
#  GIT_REPO=git@github.com:causes/puppet-configs.git \
#  ./checkout_and_update.sh \
#  /tmp/git_deploy/deploys/ ee86581468b6a8bc56b840e388c009578958f0f6

deploys_dir=$1
revision=$2
repo_dir=$REPO_DIR
git_repo=$GIT_REPO

if [ ! -d $repo_dir ]
  then
    echo "Repo dir does not exist; creating now -- this may take a while"
    mkdir -p $repo_dir && cd $git_repo && git clone $git_repo
    if [ "$?" -ne "0" ]; then
      echo "There was a problem cloning repo from $git_repo into $repo_dir"
      exit -1
    fi
  else
    echo "Fetching"
    cd $repo_dir && git fetch
    if [ "$?" -ne "0" ]; then
      echo "There was a problem resetting to revision $revision"
      exit -1
    fi
fi
# at the end of this step, we now have an up-to-date repository
# and the CWD is $git_repo

git reset --hard $revision && \
git submodule --quiet sync && \
git submodule --quiet update --init && \
git submodule --quiet foreach git reset --hard HEAD && \
git submodule --quiet foreach git clean -f
if [ "$?" -ne "0" ]; then
  echo "There was a problem updating to revision $revision"
  exit -1
fi

# at this point the repository is up to date and it's time to make a copy into
# the deployment directory
if [ ! -d $deploys_dir ]; then
  echo "Deployment directory $deploy does not exist."
  exit -1
fi

deploy_dir=$deploys_dir/$(date +%y-%m-%d-%H:%M)-$revision
echo "Hard-copying into $deploy_dir"
rsync -a $repo_dir/ $deploy_dir --exclude '.git*'
if [ "$?" -ne "0" ]; then
  echo "There was a problem copying into $deploy_dir"
  exit -1
fi

# update the symlink to current
rm $deploys_dir/current
cd $deploys_dir && ln -s $deploy_dir current

# restart the webserver
touch $deploy_dir/tmp/restart.txt
