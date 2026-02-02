FROM denoland/deno:alpine-2.6.7@sha256:454b4d685f9e8f35e41f838aa5ca297769f4ee18ee0f4814329b51af2c4c9e7c

WORKDIR /app
# Prefer not to run as root.
USER deno

COPY . .
RUN deno install
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache main.ts

CMD ["run", "-P", "main.ts"]