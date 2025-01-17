FROM python:3.8-slim

ARG AIRFLOW_VERSION=2.8.0
ARG PYTHON_VERSION=3.8
ARG AIRFLOW_HOME=/usr/local/airflow
ENV SLUGIFY_USES_TEXT_UNIDECODE=yes
ENV CONFIG_ROOT_DIR=/usr/local/airflow/dags/

RUN set -ex \
    && buildDeps=' \
    freetds-dev \
    python3-dev \
    libkrb5-dev \
    libsasl2-dev \
    libssl-dev \
    libffi-dev \
    libpq-dev \
    git \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
    && apt-get install curl -y \
    $buildDeps \
    freetds-bin \
    build-essential \
    python3-pip \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && pip install -U pip setuptools wheel \
    && apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
    /usr/share/man \
    /usr/share/doc \
    /usr/share/doc-base

ARG CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-$AIRFLOW_VERSION/constraints-$PYTHON_VERSION.txt"
RUN curl -sSL $CONSTRAINT_URL -o /tmp/constraint.txt
# Workaround to remove PyYAML constraint that will work on both Linux and MacOS
RUN sed '/PyYAML==/d' /tmp/constraint.txt > /tmp/constraint.txt.tmp
RUN mv /tmp/constraint.txt.tmp /tmp/constraint.txt

RUN pip install apache-airflow[http]==${AIRFLOW_VERSION}  --constraint /tmp/constraint.txt
ADD . /
RUN pip install -e .

RUN chmod +x /scripts/entrypoint.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]
