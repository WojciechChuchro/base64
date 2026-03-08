FROM debian:bookworm-slim AS builder

ARG ZIG_VERSION=0.14.0
ARG ZIG_ARCH=x86_64

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /zig
RUN curl -fsSL "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz" -o zig.tar.xz \
    && tar -xf zig.tar.xz \
    && mv "zig-linux-${ZIG_ARCH}-${ZIG_VERSION}" zig-toolchain

ENV PATH="/zig/zig-toolchain:${PATH}"

WORKDIR /app
COPY build.zig build.zig.zon ./
COPY src ./src

RUN zig build

FROM debian:bookworm-slim

WORKDIR /app
COPY --from=builder /app/zig-out/bin/main .

CMD ["./main"]
