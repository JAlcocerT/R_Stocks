# Deploy Me!

## Quick - Use The GHCR Image

* Visit and check the version you want to deploy:
    * <https://github.com/users/JAlcocerT/packages/container/package/r-stocks>
* Execute: `docker run -p 3838:3838 ghcr.io/jalcocert/r-stocks:latest`
    * You can also do it via [Docker Compose](https://github.com/JAlcocerT/R_Stocks/blob/main/Z_Deploy_Me/Docker-compose.yml).
* Go to your browser: `localhost:3838`


## [Build](https://fossengineer.com/building-docker-container-images/) Me ❤️

* Get Docker installed
* Clone this repository
* Execute:

```sh
docker build -t r_stocks .
podman build -t r_stocks .

sudo docker run -p3838:3838 -detached podman build -t r_stocks .
```


<details>
  <summary>Click to expand/close the visualizations tools</summary>
  &nbsp;

```sh
sudo DOCKER_BUILDKIT=1 docker build --no-cache --progress=plain -t jalcocert/rstocks .
sudo docker run -p 3838:3838 --name rstonkss -detached jalcocert/rstocks

sudo docker login
sudo docker push yourdockerhub/rstocks
```
</details>


* And then: `docker run -p 3838:3838 r_stocks`
* Go to your browser: `localhost:3838`