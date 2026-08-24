FROM denoland/deno:alpine-2.9.5@sha256:b429777c3dcff34a6488f365a1537db1640b2d48379b60f5e6206be034472463 AS builder

WORKDIR /app
COPY . .
RUN deno install
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache main.ts

# Distroless has no shell/package manager, so deno install/cache must happen in the builder stage above.
FROM denoland/deno:distroless-2.9.5@sha256:1bc3ce768279a9fb68e289916d8c33d6d10e002c18ddaf57f62a35daca0e5691

WORKDIR /app
COPY --from=builder /app /app
COPY --from=builder /deno-dir /deno-dir

CMD ["run", "-P", "main.ts"]
