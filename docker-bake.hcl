target "prepare" {
  context    = "."
  dockerfile = "Dockerfile.build"
  target     = "prepare"

  cache-from = [
    "type=registry,ref=lopezator/cache-test:latest",
    "type=gha,scope=/go/pkg/mod"
  ]

  cache-to = [
    "type=registry,ref=lopezator/cache-test:latest,mode=max",
    "type=gha,scope=/go/pkg/mod,mode=max"
  ]

  output = [
    "type=docker"
  ]
}

target "sanity-check" {
  context    = "."
  dockerfile = "Dockerfile.build"
  target     = "sanity-check"

  cache-from = [
    "type=gha,scope=/go/pkg/mod",
    "type=gha,scope=/root/.cache/go-build",
    "type=gha,scope=/root/.cache/golangci-lint"
  ]

  cache-to = [
    "type=gha,scope=/go/pkg/mod,mode=max",
    "type=gha,scope=/root/.cache/go-build,mode=max",
    "type=gha,scope=/root/.cache/golangci-lint,mode=max"
  ]

  output = [
    "type=docker"
  ]
}

target "build" {
  context    = "."
  dockerfile = "Dockerfile.build"
  target     = "build"

  cache-from = [
    "type=gha,scope=/go/pkg/mod",
    "type=gha,scope=/root/.cache/go-build"
  ]

  cache-to = [
    "type=gha,scope=/go/pkg/mod,mode=max",
    "type=gha,scope=/root/.cache/go-build,mode=max"
  ]

  output = [
    "type=docker"
  ]
}

target "release" {
  context    = "."
  dockerfile = "Dockerfile.build"
  target     = "runtime"

  cache-from = [
    "type=gha"
  ]

  cache-to = [
    "type=gha,mode=max"
  ]

  tags = [
    "docker.io/lopezator/cache-test:latest"
  ]

  output = [
    "type=docker"
  ]
}