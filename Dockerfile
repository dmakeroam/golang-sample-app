# ---- Stage 1: build the binary ----
FROM golang:1.26-alpine AS build
WORKDIR /src

COPY go.mod ./
RUN go mod download

COPY . .
# CGO_ENABLED=0 produces a fully static binary with no C library dependencies
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/server .

# ---- Stage 2: the runtime image ----
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/server /server
USER 65532:65532
EXPOSE 8080
ENTRYPOINT ["/server"]
