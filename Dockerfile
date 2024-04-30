# Step 1: Build stage
FROM golang:1.18 AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o smtprelay

# Step 2: Create a small image
FROM scratch

# Import the user and group files from the builder stage.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Copy our static executable.
COPY --from=builder /app/smtprelay /usr/bin/smtprelay

# Use an unprivileged user.
USER nobody:nobody

# Expose port 2525 (default smtprelay port)
EXPOSE 25

# Command to run
ENTRYPOINT ["smtprelay"]
