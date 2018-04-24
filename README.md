jenkins setup with taurus and siege driver configured for ssl

# install and run

```sh
# start server on localhost:8081
docker-compose up

# shell session
container exec -u root -it <your_container_id> bash
```

## create a job

you can now access bzt within a jenkins shell

```
# this file lives at ./build/taurus.yml for editing on host
bzt $JENKINS_HOME/taurus.yml
```

where you can add or edit test scenarios


## misc

```sh
# building images
docker image build -t jenkins -f Dockerfile-jenkins .
docker image build -t server -f Dockerfile-server .
```
