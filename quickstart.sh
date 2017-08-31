#!/bin/bash

if [ ! -d sample-apps ]
then
    git clone https://github.com/vespa-engine/sample-apps.git
else
    cd sample-apps
    git pull https://github.com/vespa-engine/sample-apps.git
	cd ..
fi

if [ ! "$(docker ps -q -f name=vespa)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=vespa)" ]; then
        docker rm vespa
    fi
	docker run --detach --name vespa --hostname vespa-container --privileged --volume $PWD/sample-apps:/vespa-sample-apps --publish 8080:8080 vespaengine/vespa
fi

echo "Waiting for Vespa config to start up"
sleep 5

docker exec vespa sh -c "/opt/vespa/bin/vespa-deploy prepare /vespa-sample-apps/basic-search/src/main/application && /opt/vespa/bin/vespa-deploy activate"

echo "Waiting for the application to be ready..."
until $(curl --output /dev/null --fail -s --head http://localhost:8080/ApplicationStatus); do
    printf '.'
    sleep 5
done

echo "Vespa is ready!"
