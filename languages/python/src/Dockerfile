# syntax = docker/dockerfile:1.2
# ref: https://engineers.ffri.jp/entry/2021/05/17/191143
ARG PYTHON_VERSION=3.10-slim
ARG POETRY_VERSION=1.1.12
ARG SITE_PACKAGES_PATH='/usr/local/lib/python3.10/site-packages'
ARG SOURCE_CODE_PATH='./src'
ARG WORKING_DIRPATH='/workspace'
FROM python:${PYTHON_VERSION} AS python-base
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=${POETRY_VERSION} \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_CREATE=false \
    PYSETUP_PATH="/opt/pysetup"
ENV PATH="${POETRY_HOME}/bin:${PATH}"

FROM python-base AS poetry-base
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        build-essential \
        git \
        cmake && \
    curl -sSL https://install.python-poetry.org | python -

WORKDIR ${PYSETUP_PATH}

FROM poetry-base AS project-base
ENV POETRY_NO_INTERACTION=1
COPY poetry.lock pyproject.toml ./

FROM project-base AS development
RUN --mount=type=cache,target=/root/.cache/pypoetry \
    poetry install
WORKDIR ${WORKING_DIRPATH}

FROM project-base AS builder
RUN --mount=type=cache,target=/root/.cache/pypoetry \
    poetry install --no-dev

FROM python-base AS production
COPY --from=builder ${SITE_PACKAGES_PATH} ${SITE_PACKAGES_PATH}
COPY ${SOURCE_CODE_PATH} ${WORKING_DIRPATH}
WORKDIR ${WORKING_DIRPATH}
