# Deploy Me!

## Quick - Use The GHCR Image

* Visit and check the version you want to deploy:
    * <https://hub.docker.com/repository/docker/fossengineer/r_stocks/general>
* Execute: `docker run -p 3838:3838 fossengineer/r_stocks:your_desired_version`
    * You can also do it via [Docker Compose](https://github.com/JAlcocerT/R_Stocks/blob/main/Z_Deploy_Me/Docker-compose.yml).
* Go to your browser: `localhost:3838`


## [Build](https://fossengineer.com/building-docker-container-images/) Me ❤️

* Get Docker installed
* Clone this repository
* Execute:

```sh
docker build -t r_stocks .
podman build -t r_stocks .
```
* And then: `docker run -p 3838:3838 r_stocks`
* Go to your browser: `localhost:3838`