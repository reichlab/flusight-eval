FROM rocker/r-ver:4.3.2

# install general OS utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    git

# install OS binaries required by R packages - via rocker-versioned2/scripts/install_tidyverse.sh
RUN apt-get install -y --no-install-recommends \
    libxml2-dev \
    libcairo2-dev \
    libgit2-dev \
    default-libmysqlclient-dev \
    libpq-dev \
    libsasl2-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    libxtst6 \
    libcurl4-openssl-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    unixodbc-dev \
    pandoc

# install the `gh` GitHub CLI binary
RUN apt update && apt install -y curl gpg
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg;
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null;
RUN apt update && apt install -y gh;

# install required Python packages using pip
RUN apt-get update && apt-get install -y python3-pip

WORKDIR /app
COPY requirements.txt requirements.txt
RUN python3 -m pip install -r requirements.txt

# install required R packages using renv
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

ENV RENV_PATHS_LIBRARY renv/library
COPY renv.lock renv.lock
RUN R -e "renv::restore()"

# clone https://github.com/reichlab/container-utils. ADD is a hack ala https://stackoverflow.com/questions/35134713/disable-cache-for-specific-run-commands
ADD "https://api.github.com/repos/reichlab/container-utils/commits?per_page=1" latest_commit
RUN git clone https://github.com/reichlab/container-utils.git

COPY code ./code
COPY docker/run-make-eval-reports.sh .

CMD ["bash", "/app/run-make-eval-reports.sh"]
