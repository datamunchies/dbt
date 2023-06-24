# this is a test Dockerfile -- DO NOT USE YET
FROM python:3.11.1-slim-bullseye as base

# will install only dbt-core and dbt-bigquery adapter
ARG dbt_core_ref=dbt-core
ARG dbt_bigquery_ref=dbt-bigquery
ARG dbt_clickhouse_ref=dbt-clickhouse

# System setup
RUN apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y python-dev --no-install-recommends -y -q \
    zsh \
    git \
    nano \
    curl \
    ssh-client \
    build-essential \
    ca-certificates \
    libpq-dev && \
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Env vars
ENV PYTHONIOENCODING=utf-8
ENV LANG=C.UTF-8
ENV DBT_DIR /dbt

# Update python
RUN python -m pip install --upgrade pip setuptools wheel numpy --no-cache-dir

# install dbt-core, dbt-bigquery, and dbt-clickhouse
FROM base as dbt-plugins

# add a system user with UID 1000 for all docker images that use this Dockerfile
RUN adduser --system --uid 1000 appuser

RUN python -m pip install --no-cache-dir "git+https://github.com/dbt-labs/${dbt_core_ref}#egg=dbt-core&subdirectory=core"
RUN python -m pip install --no-cache-dir "git+https://github.com/dbt-labs/${dbt_bigquery_ref}#egg=dbt-bigquery"
RUN python -m pip install --no-cache-dir "git+https://github.com/ClickHouse/${dbt_clickhouse_ref}#egg=dbt-clickhouse"


COPY ./profiles.yml $DBT_DIR/profiles.yml
COPY ./models $DBT_DIR/models
COPY ./tests $DBT_DIR/tests
COPY ./target $DBT_DIR/target
COPY ./dbt_packages $DBT_DIR/dbt_packages
COPY ./dbt_modules $DBT_DIR/dbt_modules
COPY ./macros $DBT_DIR/macros
COPY ./tests $DBT_DIR/tests
COPY ./logs $DBT_DIR/logs
COPY ./seeds $DBT_DIR/seeds
COPY ./snapshots $DBT_DIR/snapshots

COPY ./scripts/readinessProbe.sh $DBT_DIR/readinessProbe.sh
COPY ./scripts/livenessProbe.sh $DBT_DIR/livenessProbe.sh

# Set working directory
WORKDIR $DBT_DIR

# change owner for /dbt directory
RUN chown -R appuser $DBT_DIR

RUN chmod +x $DBT_DIR/readinessProbe.sh
RUN chmod +x $DBT_DIR/livenessProbe.sh

USER appuser

ENTRYPOINT ["tail","-f", "/dev/null"]