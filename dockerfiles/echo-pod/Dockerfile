# Use an appropriate base image
FROM alpine:latest

# Create a script to print the pod name
RUN echo -e '#!/bin/sh\nhostname' > /usr/local/bin/print_pod_name.sh

# Set the script as executable
RUN chmod +x /usr/local/bin/print_pod_name.sh

# Define the command to run when the container starts
CMD ["/usr/local/bin/print_pod_name.sh"]
