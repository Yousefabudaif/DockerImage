# -------------- Build stage
FROM golang:1.22 AS builder

WORKDIR /app
COPY go.mod ./
RUN go mod download

COPY . .
# Static binary for a small final image
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o server .

# -------------- Run stage
FROM gcr.io/distroless/static:nonroot
WORKDIR /app

# The app writes to ./users_saved; ensure it exists and is writable
USER nonroot:nonroot
COPY --from=builder /app/server /app/server

EXPOSE 8080
ENTRYPOINT ["/app/server"]
