#!/bin/bash

# Get the hostname (which is the pod name in Kubernetes)
POD_NAME=$(hostname)

# Get the node name from env variables
NODE_NAME=$NODE_NAME

# Replace the placeholders in the HTML with the actual pod name and node name
sed -i "s/{{POD_NAME}}/${POD_NAME}/g" /usr/share/nginx/html/index.html
sed -i "s/{{NODE_NAME}}/${NODE_NAME}/g" /usr/share/nginx/html/index.html

# Start Nginx
nginx -g 'daemon off;'
