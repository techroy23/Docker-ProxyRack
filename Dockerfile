FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache \
      curl jq bash \
      netcat-openbsd \
      ca-certificates \
      gcompat

RUN curl -fsSL --retry 5 --retry-delay 2 -A "Mozilla/5.0" \
      -o /app/ProxyRack "https://app-updates.sock.sh/peerclient/go/client" \
    && chmod +x /app/ProxyRack

COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh /app/ProxyRack

ENTRYPOINT ["/app/entrypoint.sh"]
