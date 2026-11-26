FROM denoland/deno:alpine@sha256:75749604f68aea01d39bead15fd1c86343639e44eb8c58ab051da8a924799d01 AS builder

WORKDIR /app
COPY . .
# .npmrc only contains a ${NODE_AUTH_TOKEN} placeholder; the secret is mounted at build time and never stored in a layer.
RUN --mount=type=secret,id=NODE_AUTH_TOKEN,env=NODE_AUTH_TOKEN \
    deno install --frozen && \
    # Compile the main app so that it doesn't need to be compiled each startup/entry.
    deno cache --frozen main.ts

# Distroless has no shell/package manager, so deno install/cache must happen in the builder stage above.
FROM denoland/deno:distroless@sha256:88882a0c54683c0953cdc26684e02111aa93c1f66e8c489900281ae4a3f5c8ad

WORKDIR /app
COPY --from=builder /app /app
COPY --from=builder /deno-dir /deno-dir

CMD ["run", "-P", "main.ts"]
