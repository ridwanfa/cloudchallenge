# Uses the official Nginx image with Alpine Linux as base 
# Alpine used to keep image size small
FROM nginx:alpine   

# Install OpenSSL and generate self-signed SSL cert and key
RUN apk add --no-cache openssl && \

# Creates folder where cert and key will be saved
    mkdir -p /etc/nginx/certs && \

# Cert request 
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \

# Tells OpenSSL where to save private key inside container
    -keyout /etc/nginx/certs/cert.key \

# Tells OpenSSL where to save cert inside container
    -out /etc/nginx/certs/cert.crt \

# Skips interactive prompts and sets domain to localhost
    -subj "/CN=localhost"

# Copy website files into Nginx web root directory
COPY . /usr/share/nginx/html

# Replace default Nginx config with mine
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for HTTP traffic
EXPOSE 80

# Expose port 443 for HTTPS traffic
EXPOSE 443

# Start Nginx in foreground so Docker can monitor it
CMD ["nginx", "-g", "daemon off;" ]

