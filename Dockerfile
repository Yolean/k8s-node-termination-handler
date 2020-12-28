# build stage
FROM golang:1.15.6-buster@sha256:f07de066d08e36e8c84da118bea13b448bc085364f6fc724c44744f6114c21a4 AS build-env
WORKDIR /go/src/github.com/GoogleCloudPlatform/k8s-node-termination-handler
ENV GO111MODULE=on
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -tags netgo -o node-termination-handler && go test ./...

# final stage
FROM gcr.io/distroless/static@sha256:04c5f0473b7ebba65bfdd4125fe81fac1701783549f9b98fd96e3566f6035fa7
WORKDIR /app
COPY --from=build-env /go/src/github.com/GoogleCloudPlatform/k8s-node-termination-handler/node-termination-handler /app/
ENTRYPOINT [ "./node-termination-handler" ]
