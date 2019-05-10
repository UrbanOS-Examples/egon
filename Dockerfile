FROM bitwalker/alpine-elixir:1.8.1 as builder
ARG HEX_TOKEN
COPY . /app
WORKDIR /app
RUN apk update && \
    apk --no-cache --update upgrade alpine-sdk && \
    apk --no-cache add alpine-sdk && \
    rm -rf /var/cache/**/*
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.organization auth smartcolumbus_os --key ${HEX_TOKEN} && \
    mix deps.get && \
    mix format --check-formatted && \
    mix credo && \
    mix test
RUN MIX_ENV=prod mix release

FROM bitwalker/alpine-elixir:1.8.1
ENV REPLACE_OS_VARS=true
WORKDIR /app
COPY --from=builder /app/_build/prod/rel/egon/ .
CMD ["bin/egon", "foreground"]
