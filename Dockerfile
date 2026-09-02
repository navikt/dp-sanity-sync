FROM denoland/deno:alpine@sha256:b49ac52f05c3d8d0da890b6628168e9bfb5721f7bccc00305bb3ad29ed0e40af AS builder

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
