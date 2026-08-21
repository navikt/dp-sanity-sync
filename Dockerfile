FROM denoland/deno:alpine-2.9.5@sha256:b429777c3dcff34a6488f365a1537db1640b2d48379b60f5e6206be034472463

WORKDIR /app
# Prefer not to run as root.
USER deno

COPY . .
RUN deno install
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache main.ts

CMD ["run", "-P", "main.ts"]
