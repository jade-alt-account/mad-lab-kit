podman stats --no-stream
podman stop web && podman rm web
time podman run -d --name web --memory 64m -p 8080:80 \
     docker.io/library/nginx:stable
podman stats --no-stream
