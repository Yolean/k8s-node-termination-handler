# build stage
FROM golang:latest AS build-env
WORKDIR /go/src/github.com/GoogleCloudPlatform/k8s-node-termination-handler
ENV GO111MODULE=on
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -tags netgo -o node-termination-handler && go test ./...

# final stage
FROM gcr.io/distroless/static:latest
WORKDIR /app
COPY --from=build-env /go/src/github.com/GoogleCloudPlatform/k8s-node-termination-handler/node-termination-handler /app/
ENTRYPOINT [./node-termination-handler]
