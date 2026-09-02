FROM denoland/deno:alpine@sha256:aa665f8777136863b5b8a0445a5cdfccff8103b5f40c9a877de5276b04facb1e AS builder

WORKDIR /app
COPY . .
RUN deno install
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache main.ts

# Distroless has no shell/package manager, so deno install/cache must happen in the builder stage above.
FROM denoland/deno:distroless@sha256:1bc3ce768279a9fb68e289916d8c33d6d10e002c18ddaf57f62a35daca0e5691

WORKDIR /app
COPY --from=builder /app /app
COPY --from=builder /deno-dir /deno-dir

CMD ["run", "-P", "main.ts"]
