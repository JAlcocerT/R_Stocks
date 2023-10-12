# Deploy Me!

## Quick - Use my DockerHub Image

* Visit and check the version you want to deploy: <https://hub.docker.com/repository/docker/fossengineer/r_stocks/general>
* Execute: docker run -p 3838:3838 fossengineer/r_stocks:your_desired_version
* Go to your browser: localhost:3838


## [Build](https://fossengineer.com/building-docker-container-images/) Me

* Get Docker installed
* Clone this repository
* Execute: docker build -t r_stocks .
* And then: docker run -p 3838:3838 r_stocks 
* Go to your browser: localhost:3838