FROM python:3.12-alpine3.22
LABEL maintainer="Oauroboarus Developer"

ENV PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
# Install system dependencies first
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    postgresql-dev \
    jpeg-dev \
    zlib-dev \
    shadow && \
  python -m venv /py && \
  /py/bin/pip install --upgrade pip && \
  /py/bin/pip install --no-cache-dir -r /tmp/requirements.txt && \
  if [ "$DEV" = "true" ]; then /py/bin/pip install --no-cache-dir -r /tmp/requirements.dev.txt; fi && \
  rm -rf /root/.cache && \
  adduser \
    --disabled-password \
    --no-create-home \
    django-user && \
  chown -R django-user:django-user /app && \
  apk del gcc musl-dev shadow

ENV PATH="/py/bin:$PATH"

USER django-user
