podman build --tag arre .

podman run --rm -d -p 6080:6080 --name novnc-arch arre 

firefox localhost:6080/vnc.html

