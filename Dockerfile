FROM denoland/deno:alpine@sha256:8ce780168429c4bf5962652e6cbea3fd45254ae902069e90585fb33f74c56968 AS builder

WORKDIR /app
COPY . .
RUN deno install
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache main.ts

# Distroless has no shell/package manager, so deno install/cache must happen in the builder stage above.
FROM denoland/deno:distroless@sha256:d4f10b07f7e7a9969a4a8c585f388783f31a1be6d630a521f9219b6edbf5935d

WORKDIR /app
COPY --from=builder /app /app
COPY --from=builder /deno-dir /deno-dir

CMD ["run", "-P", "main.ts"]
