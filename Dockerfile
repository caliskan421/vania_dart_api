# Use latest stable channel SDK.
FROM dart:stable AS build

# Work Directory
WORKDIR /app

# Resolve app dependencies.
COPY pubspec.* ./

# Install the Vania cli from pub.dev
RUN dart pub global activate vania_cli

# Get dependencies
RUN dart pub get

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY . .

# 📦 Create a production build
RUN dart pub get --offline

# Migration build sırasında DB bağlantısı gerektirir - Railway'de deploy sonrası ayrı çalıştırılır
RUN vania build

# Use debian-slim for shell support (Railway PORT env var)
FROM debian:bookworm-slim

# dart compile exe standalone binary üretir - /runtime/ gerekmez
COPY --from=build /app/bin/server /bin/server
# .env kopyalanmaz - Railway env variables kullanılır (güvenlik)
COPY --from=build /app/public /public/
COPY --from=build /app/storage /storage/
COPY --from=build /app/lib/lang /lib/lang
COPY --from=build /app/lib/resources /lib/resources

# Railway: PORT env var is set at runtime. Vania uses APP_PORT.
# Use --port when PORT is set so app binds to Railway's assigned port.
RUN echo '#!/bin/sh\n\
if [ -n "$PORT" ]; then\n\
  exec /bin/server -p "$PORT"\n\
else\n\
  exec /bin/server\n\
fi' > /start.sh && chmod +x /start.sh

# Expose the server port (Railway uses PORT, default 8080)
EXPOSE 8080

WORKDIR /

# Start server (supports Railway PORT via -p flag)
CMD ["/start.sh"]