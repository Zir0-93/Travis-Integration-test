#! /bin/bash
if [[ $TRAVIS_EVENT_TYPE == 'push' ]]; then
	if [[ $TRAVIS_BRANCH == 'master' ]]; then
		echo "ok to deploy!"
		curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github"  |   tar -zx
		export PATH=$PATH:.
		cf --version
		cf install-plugin -f https://static-ice.ng.bluemix.net/ibm-containers-linux_x64
		cf plugins
		cf login -a https://api.ng.bluemix.net -u kdang@ca.ibm.com -p $secretpw
		cf ic login
		cf ic images
		docker build -t tom_cat .
		docker tag tom_cat registry.ng.bluemix.net/ahhhh/tom_cat
		docker push registry.ng.bluemix.net/ahhhh/tom_cat
		cf ic images
		cf ic ps -a
		cf ic rename tom_cat old_tom_cat
		cf ic run -p 8080 --name tom_cat registry.ng.bluemix.net/ahhhh/tom_cat
		sleep 60
		cf ic ip unbind 169.44.122.107 old_tom_cat
		cf ic ip bind 169.44.122.107 tom_cat
		cf ic ps -a
		cf ic rm -f old_tom_cat
	else
		echo "push to non-master branch"
	fi
else
	echo "Is it a pull request?"
	echo "$TRAVIS_PULL_REQUEST"
fi