# FROM rocker/shiny:3.6.1
# WORKDIR /srv/shiny-serverRUN apt-get update \
#     && apt-get install -y libsasl2-dev libssl-devRUN echo \
#   'options(repos=list(CRAN="https://cloud.r-project.org/"))' > \
#   ".Rprofile"
# RUN R -e "install.packages(c('dplyr','tidyr', 'plotly'))"ADD https://raw.githubusercontent.com/rocker-org/shiny/master/shiny-server.sh /usr/bin/
# COPY ./ ./
# EXPOSE 3838
# RUN chmod a+w .
# # RUN chmod +x /usr/bin/shiny-server.sh
# CMD /usr/bin/shiny-server.sh


# # FROM rocker/shiny:3.6.1
# # LABEL maintainer "Meinhard Ploner <dummy@host.com>"WORKDIR /srv/shiny-serverRUN apt-get update \
# #     && apt-get install -y libsasl2-dev libssl-devRUN echo \
# #   'options(repos=list(CRAN="https://cloud.r-project.org/"))' > \
# #   ".Rprofile"
# # RUN R -e "install.packages(c('dplyr','tidyr', 'plotly'))"ADD https://raw.githubusercontent.com/rocker-org/shiny/master/shiny-server.sh /usr/bin/
# # COPY ./ ./
# # EXPOSE 3838
# # RUN chmod a+w .
# # # RUN chmod +x /usr/bin/shiny-server.sh
# # CMD /usr/bin/shiny-server.sh


# #################### Building from shiny docker image ###################3

# FROM rocker/shiny

# WORKDIR /srv/shiny-server

# RUN apt-get update \
#     && apt-get install -y libsasl2-dev libssl-dev 

# RUN echo 'options(repos=list(CRAN="https://cloud.r-project.org/"))' > ".Rprofile"
# RUN R -e "install.packages(c('dplyr','tidyr', 'plotly'))"

# COPY ./ ./ 
# COPY ./shiny-server.sh /usr/bin/shiny-server.sh

# EXPOSE 3838

# RUN chmod -R 777 .

# CMD ["/usr/bin/shiny-server.sh"]

# ##############################OKISH###############################

# # FROM rocker/shiny:3.6.1
# # LABEL maintainer "Meinhard Ploner <dummy@host.com>"

# # WORKDIR /srv/shiny-serverRUN apt-get update \
# #     && apt-get install -y libsasl2-dev libssl-devRUN echo \
# #   'options(repos=list(CRAN="https://cloud.r-project.org/"))' > \
# #   ".Rprofile"

# # RUN R -e 'install.packages(c("shiny", "plotly", "dplyr", "tidyr","lubridate","shinythemes","shinyWidgets","DT","bslib","priceR","quantmod"))'

# # RUN R -e 'install.packages("yfR", dependencies = TRUE)'

# # ADD https://raw.githubusercontent.com/rocker-org/shiny/master/shiny-server.sh /usr/bin/

# # COPY ./ ./
# # EXPOSE 3838
# # RUN chmod a+w .
# # RUN chmod +x /usr/bin/shiny-server.sh
# # CMD /usr/bin/shiny-server.sh



# # Instead of using rocker/shiny:3.6.1, you can use rocker/tidyverse:3.6.1 and install the shiny package separately. 
# # This will make your app available on port 3838 without the need for Shiny Server stackoverflow.com.
# #https://hub.docker.com/r/rocker/tidyverse

# ########################################################


# # FROM rocker/tidyverse:3.6.1

# # RUN R -e 'install.packages(c("shiny", "plotly", "dplyr", "tidyr","lubridate","shinythemes","shinyWidgets","DT","bslib","priceR","quantmod"))'

# # RUN R -e 'install.packages("yfR", dependencies = TRUE)'

# # COPY app.R /app.R

# # EXPOSE 3838

# # CMD R -e 'shiny::runApp("app.R", port = 3838, host = "0.0.0.0")'


# ###########################OK##################################

FROM rocker/tidyverse:4 
LABEL maintainer "JAlcocerT"
LABEL org.opencontainers.image.source https://github.com/JAlcocerT/R_Stocks

RUN R -e 'install.packages(c("shiny", "plotly", "viridis","dplyr", "tidyr","lubridate","shinythemes","shinyWidgets","DT","bslib","priceR","quantmod"))'

RUN R -e 'install.packages("yfR", dependencies = TRUE)'
#RUN R -e 'install.packages("yfR", repos = "https://ropensci.r-universe.dev", dependencies = TRUE)'

COPY app.R /app.R

EXPOSE 3838

CMD R -e 'shiny::runApp("app.R", port = 3838, host = "0.0.0.0")'


# ####################################################################



# ########################casi casi############################

# #https://hub.docker.com/r/rocker/r-ver

# # FROM rocker/r-ver:4.1.2
# # #FROM r-base:4.1.2
# # #r-base:latest
# # #r-ver:4.1.2
# # LABEL maintainer="USER <user@example.com>"
# # RUN apt-get update && apt-get install -y --no-install-recommends \
# #     sudo \
# #     libcurl4-gnutls-dev \
# #     libcairo2-dev \
# #     libxt-dev \
# #     libssl-dev \
# #     libssh2-1-dev \
# #     && rm -rf /var/lib/apt/lists/*


# # #https://stackoverflow.com/questions/45289764/install-r-packages-using-docker-file
# # RUN R -e "install.packages('littler', dependencies=TRUE)"
# # #RUN install2.r --error --deps TRUE methods
# # RUN install2.r --error --deps TRUE yfR

# # # Install remotes package
# # RUN R -e 'install.packages("remotes")'


# # # Install specific versions of Shiny and Plotly, along with their dependencies
# # RUN R -e 'remotes::install_version("plotly", version = "4.9.3", dependencies = TRUE)'
# # RUN R -e 'remotes::install_version("shiny", version = "1.6.0", dependencies = TRUE)'
# # RUN R -e 'install.packages(c("dplyr", "tidyr","lubridate","shinythemes","shinyWidgets","DT","bslib","priceR","quantmod"))'
# # #RUN R -e 'install.packages(c("shiny", "plotly", "dplyr", "tidyr","lubridate","shinythemes","shinyWidgets","DT","bslib","priceR","quantmod"))'
# # #RUN R -e 'install.packages("yfR", dependencies = TRUE)'
# # #RUN R -e 'remotes::install_version("yfR", dependencies = TRUE)'


# # # Copy app.R to the container
# # COPY app.R /srv/shiny-server/app.R

# # # Expose the required port
# # EXPOSE 3838

# # # Set the CMD to run the Shiny app
# # CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/app.R', host = '0.0.0.0', port = 3838)"]

# ############################################
# # FROM rocker/r-base:4.1.2
# # #FROM rocker/r-ver:4.1.2
# # LABEL maintainer="USER <user@example.com>"

# # RUN apt-get update && apt-get install -y --no-install-recommends \
# #     sudo \
# #     libcurl4-gnutls-dev \
# #     libcairo2-dev \
# #     libxt-dev \
# #     libssl-dev \
# #     libssh2-1-dev \
# #     && rm -rf /var/lib/apt/lists/*

# # RUN R -e "install.packages('littler', dependencies=TRUE)"
# # RUN R -e 'install.packages("remotes")'

# # #Rscript -e "cat(Sys.getenv('R_HOME'), '/etc/Renviron', sep='')"


# # RUN ls -l /usr/local/lib/R/etc/Renviron

# # RUN find / -name libR.so

# # RUN ldconfig

# # COPY /usr/local/lib/R/etc/Renviron /usr/local/lib/R/etc/Renviron


# # ENV LD_LIBRARY_PATH="/usr/local/lib/R/lib:$LD_LIBRARY_PATH"
# # RUN ls -l /usr/local/lib/R/lib/libR.so
# # RUN chmod +r /usr/local/lib/R/lib/libR.so


# # RUN install2.r --error --deps TRUE yfR@1.1.0

# # COPY app.R /srv/shiny-server/app.R
# # EXPOSE 3838
# # CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/app.R', host = '0.0.0.0', port = 3838)"]




# ########################## Building from Ubuntu ####################### 

# # sudo DOCKER_BUILDKIT=1 docker build --no-cache --progress=plain -t rstocks_ubuntu .
# #sudo DOCKER_BUILDKIT=1 docker build --no-cache --progress=plain -t rstocks_ubuntu . --log-opt mode=append --log-opt max-size=10m --log-opt max-file=3
# #sudo DOCKER_BUILDKIT=1 docker build --no-cache --progress=plain -t rstocks_ubuntu . > build_log.txt 2>&1


# #d ocker build -t my_image_name -f Dockerfile > build_log.txt 2>&1
# #sudo DOCKER_BUILDKIT=1 docker build --no-cache --progress=plain -t rstocks_ubuntu -f Dockerfile > build_log.txt 2>&1
# # docker run --name stocksubuntu -p 3836:3838 --detach rstocks_ubuntu44

# FROM ubuntu:20.04
# LABEL maintainer="USER <user@example.com>"

# # Set the environment variable to prevent interactive prompts
# ENV DEBIAN_FRONTEND=noninteractive

# # Install required system dependencies
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     software-properties-common \
#     dirmngr \
#     gpg-agent \
#     build-essential \
#     make \
#     && rm -rf /var/lib/apt/lists/*

# # Add R repository and install R
# RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
# RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     r-base \
#     && rm -rf /var/lib/apt/lists/*

# # Set R environment variables
# ENV R_HOME=/usr/lib/R
# ENV PATH=$PATH:/usr/lib/R/bin

# # Install additional system dependencies
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     libcurl4-gnutls-dev \
#     libcairo2-dev \
#     libxt-dev \
#     libssl-dev \
#     libssh2-1-dev \
#     && rm -rf /var/lib/apt/lists/*

# # Install R packages
# RUN R -e "install.packages(c('littler', 'remotes'), repos='https://cloud.r-project.org/')"

# # Install specific version of yfR package
# #RUN R -e "remotes::install_version('yfR', version='1.1.0')"
# # Install specific versions of Shiny and Plotly, along with their dependencies
# #RUN R -e 'remotes::install_version("plotly", version = "4.9.3", dependencies = TRUE)'
# #RUN R -e 'remotes::install_version("shiny", version = "1.6.0", dependencies = TRUE)'

# RUN R -e 'install.packages(c("shiny", "plotly"))'

# RUN R -e 'install.packages(c("dplyr", "tidyr","lubridate","shinythemes","shinyWidgets","DT","bslib","priceR","quantmod"))'
# RUN R -e "remotes::install_version('yfR', version='1.1.0', dependencies = TRUE)"

# # Copy the necessary files and run the Shiny app
# COPY app.R /srv/shiny-server/app.R
# EXPOSE 3838
# CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/app.R', host = '0.0.0.0', port = 3838)"]


# ########## from alpine ############

# # FROM alpine:3.14
# # LABEL maintainer="USER <user@example.com>"

# # # Install required system dependencies
# # RUN apk update && apk add --no-cache \
# #     R \
# #     R-dev \
# #     curl-dev \
# #     cairo-dev \
# #     libxt-dev \
# #     openssl-dev \
# #     openssh \
# #     && rm -rf /var/cache/apk/*

# # # Set R environment variables
# # ENV R_HOME=/usr/lib/R
# # ENV PATH=$PATH:/usr/lib/R/bin

# # # Install R packages
# # RUN R -e "install.packages(c('littler', 'remotes'), repos='https://cloud.r-project.org/')"

# # # Install specific version of yfR package
# # RUN R -e "remotes::install_version('yfR', version='1.1.0')"

# # # Copy the necessary files and run the Shiny app
# # COPY app.R /srv/shiny-server/app.R
# # EXPOSE 3838
# # CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/app.R', host = '0.0.0.0', port = 3838)"]


# ##############################
# ###########
# ### ARM ###
# ###########

# #docker build -t my-shiny-plotly-app-arm-base .
# #docker run -p 3838:3838 my-shiny-plotly-app-arm-base


# ##########

# # FROM arm64v8/r-base:latest
# # LABEL maintainer="USER <user@example.com>"
# # RUN apt-get update && apt-get install -y --no-install-recommends \
# #     sudo \
# #     libcurl4-gnutls-dev \
# #     libcairo2-dev \
# #     libxt-dev \
# #     libssl-dev \
# #     libssh2-1-dev \
# #     && rm -rf /var/lib/apt/lists/*

# #     # Install remotes package
# # RUN R -e 'install.packages("remotes")'

# # # Install specific versions of Shiny and Plotly, along with their dependencies
# # RUN R -e 'remotes::install_version("shiny", version = "1.6.0", dependencies = TRUE)'
# # RUN R -e 'remotes::install_version("plotly", version = "4.9.3", dependencies = TRUE)'

# # # Copy app.R to the container
# # COPY app.R /srv/shiny-server/app.R

# # # Expose the required port
# # EXPOSE 3838

# # # Set the CMD to run the Shiny app
# # CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/app.R', host = '0.0.0.0', port = 3838)"]
