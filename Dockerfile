FROM python:3.13-alpine3.20
LABEL maintainer="Oauroboarus Developer"

ENV PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1

# Copy dependency files first
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false

# Install system and build dependencies
RUN apk add --no-cache \
  bash \
  libpq \
  jpeg-dev \
  zlib-dev \
  postgresql-client && \
  apk add --no-cache --virtual .build-deps \
  gcc \
  musl-dev \
  python3-dev \
  libffi-dev \
  postgresql-dev && \
  \
  python -m venv /py && \
  /py/bin/pip install --upgrade pip && \
  /py/bin/pip install --no-cache-dir -r /tmp/requirements.txt && \
  if [ "$DEV" = "true" ]; then /py/bin/pip install --no-cache-dir -r /tmp/requirements.dev.txt; fi && \
  \
  apk del .build-deps && \
  adduser --disabled-password --no-create-home django-user && \
  chown -R django-user:django-user /app

ENV PATH="/py/bin:$PATH"

USER django-user
