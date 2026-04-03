# Cloud Engineer Intern Coding Challenge

A containerized web service built with Nginx and Docker, served over HTTPS using a self-signed certificate that is automatically generated during the Docker build process.

---

## How to Run Locally

### Prerequisites
- Docker Desktop installed on your machine

### Steps

1. Clone the repository
```bash
git clone https://github.com/ridwanfa/cloudchallenge.git
cd cloudchallenge

2. Build and run the container
```bash
docker compose up --build
```

3. Open your browser and visit
```
https://localhost:8443
```

> Note: Your browser may show a security warning because the certificate is self-signed. If so, click **Advanced → Proceed** to continue.

4. To stop the container
```bash
docker compose down
```

5. To view logs in real time, open a second terminal and run
```bash
docker compose logs -f
```

---

## Design Choices

- **Nginx Alpine** — Nginx was chosen as the web server because it is lightweight, fast, and the industry standard for serving static files over HTTPS. The Alpine base image keeps the container size minimal which improves build and deployment speed.
- **Self-signed certificate generated at build time** — OpenSSL is installed and run inside the Dockerfile during the build process, automatically generating the certificate and key. This means no manual steps are required to get HTTPS working — just clone and run.
- **HTTP → HTTPS redirect** — All HTTP traffic on port 80 is automatically redirected to HTTPS on port 443, ensuring all traffic is always encrypted.
- **Docker Compose** — Allows the entire service to be started with a single command, making it easy for anyone to run locally without having to understand the underlying Docker commands.
- **Nginx logging** — Access logs and error logs are enabled in Nginx. Access logs record every request made to the server including the IP address, request type, and response code. Error logs capture any warnings or failures. Logs can be viewed in real time by running `docker compose logs -f` in a separate terminal.


---

## What I Would Improve With More Time

- Replace the self-signed certificate with a trusted certificate from Let's Encrypt to eliminate the browser security warning
- Add a CI/CD pipeline using GitHub Actions to automatically build and test the Docker image on every push
- Replace Nginx access logs with structured JSON logging to make logs easier to parse and ship to a centralized monitoring service like AWS CloudWatch or Datadog
- Run Nginx as a non-root user inside the container for better security
- Add a health check endpoint so Docker knows when the service is truly ready before accepting traffic
- Use Docker Compose volumes to mount certificates at runtime, allowing certificate rotation without rebuilding the image

---

## How I Would Deploy This to AWS

1. **Amazon ECR** — Push the Docker image to Elastic Container Registry, AWS's service for storing Docker images
2. **Amazon ECS with Fargate** — Deploy the container using Fargate, which runs containers serverlessly without needing to manage any servers
3. **Application Load Balancer** — Place a load balancer in front of the container to handle incoming traffic and HTTPS termination, replacing the need for Nginx to manage certificates directly
4. **AWS Certificate Manager** — Use ACM to provision a free, trusted, auto-renewing SSL certificate and attach it to the load balancer
5. **Route 53** — Point a domain name at the load balancer

The result mirrors this local setup exactly: traffic hits the load balancer (TLS termination) → container (plain HTTP internally).

---

## Why Storing a Private SSL Key in a Repository is Bad Practice

Anyone who possesses the private key can impersonate your server and decrypt traffic that was meant to be private. Once committed to Git it is compromised forever because:

- **Git history is permanent** — deleting the file does not remove it from past commits
- **Public repos are indexed** by search engines and secret scanning tools
- **Anyone who has cloned the repo** retains a local copy of the key

In production, private keys should be stored in a secrets manager such as AWS Secrets Manager or HashiCorp Vault and never committed to source control. In this project the certificate is generated automatically inside Docker during the build process, so no private key ever touches the repository.

---

## AI Tools Used

- **Claude (Anthropic)** — To review code