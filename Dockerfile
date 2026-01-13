FROM denoland/deno:alpine-2.6.4@sha256:b352e01d7dfb6d5d3ca83413ce5a8149f13b1a0041457ce2ae5856e100d00ff8

WORKDIR /app
# Prefer not to run as root.
USER deno

COPY . .
RUN deno install
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache main.ts

CMD ["run", "-P", "main.ts"]