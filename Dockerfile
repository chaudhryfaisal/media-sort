FROM golang:1.14 as build

WORKDIR /app

COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .
ARG GOOS=linux
ARG GOARCH=amd64
RUN CGO_ENABLED=0 GOOS=$GOOS GOARCH=$GOARCH go build -a -ldflags '-extldflags "-static"' -o media-sort . 

FROM scratch

COPY --from=build /app/media-sort /media-sort
# Import the root ca-certificates
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
#ADD ./ca-certificates-plus-charles.crt /etc/ssl/certs/ca-certificates.crt

ENTRYPOINT ["/media-sort"]
