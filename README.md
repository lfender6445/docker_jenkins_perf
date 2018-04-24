jenkins setup with taurus and siege driver configured for ssl

# install and run

```
# start server on localhost:8081
docker-compose up

# shell session
container exec -u root -it <your_container_id> bash
```

## create a job

you can now access bzt within a jenkins shell

```
bzt taurus.yml # this file lives at ./build/taurus.yml
```

where you can add or edit test scenarios
