sudo dnf -y install podman
podman run -d --name web -p 8080:80 docker.io/library/nginx:stable
podman ps
curl -I http://localhost:8080
