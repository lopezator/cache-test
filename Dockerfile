# Base stage for dependencies and tools.
FROM golang:1.23.2-bullseye AS base

# Install golangci-lint.
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$(go env GOPATH)/bin" v1.61.0

# Copy source code.
WORKDIR /go/src/github.com/lopezator/baker
COPY --link . .

# Prepare stage: Cache go modules.
FROM base AS prepare
RUN --mount=type=cache,target=/go/pkg/mod \
	make prepare

# Lint stage: Cache golangci-lint.
FROM prepare AS sanity-check
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/golangci-lint \
    make sanity-check

# Build stage: Cache Go build artifacts.
FROM prepare AS build
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
	make build

# Test stage: Cache Go test artifacts.
FROM prepare AS test
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
	make test

# Release stage: Copy binary from build stage.
FROM gcr.io/distroless/static@sha256:c6d5981545ce1406d33e61434c61e9452dad93ecd8397c41e89036ef977a88f4 AS release
COPY --from=build "/usr/local/bin/baker" "/usr/local/bin/baker"
CMD ["baker"]