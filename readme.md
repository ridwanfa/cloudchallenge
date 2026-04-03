# Cloud Engineer Intern Coding Challenge

A containerized web service built with Nginx and Docker, served over HTTPS using a self-signed certificate that is automatically generated during the Docker build process.

---

## How to Run Locally

### Ensure that:
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

- Replace the self-signed certificate with a trusted certificate from Let's Encrypt for a production-grade HTTPS setup that eliminates the browser security warning
- Introduce resource limits in the Compose file to cap CPU and memory usage, preventing the container from consuming too much of the host machine's resources
- Add a Terraform script to automate the provisioning of the AWS infrastructure mentioned above, making cloud deployment repeatable and version controlled
- Harden the container by running Nginx as a non-root user and adding a read-only filesystem where possible to reduce the attack surface
- Set up automated image vulnerability scanning using a tool like Trivy or Snyk to catch security issues in the base image before deployment

---

## How I Would Deploy This to AWS

The local setup maps directly to a standard AWS architecture:

- Store the Docker image in **ECR**
- Run it using **ECS Fargate** — no servers to manage
- Put an **Application Load Balancer** in front to handle all incoming traffic
- Attach an **ACM certificate** to the load balancer for trusted HTTPS — at this point Nginx no longer needs to handle TLS at all
- Use **Route 53** to connect a domain to the load balancer

The biggest difference from local: TLS moves from Nginx to the load balancer, which is how it works in every real production environment.

In a previous project I built a static website deployment pipeline using S3, CloudFront, and GitHub Actions. That architecture served content globally through CloudFront with OAC controlling private S3 access. This project takes a different approach — rather than serving static files directly from S3, the content is containerized and served through Nginx, which makes it more portable and closer to how real application backends are deployed. The CI/CD and IAM patterns from that project would carry over directly here, with GitHub Actions building and pushing the Docker image to ECR on every commit instead of syncing files to S3.

---

## Why Storing a Private SSL Key in a Repository is Bad Practice

Committing a private key to a repository is essentially making it public. Git history is permanent, meaning even if the file is removed in a later commit it can still be retrieved from previous ones. Beyond that, public repositories are continuously scanned by automated tools and bad actors specifically looking for exposed keys, and any clone of the repo carries a copy of the key with it. The safest approach in production is to keep private keys out of source control entirely and store them in a dedicated secrets manager like AWS Secrets Manager or HashiCorp Vault. This project sidesteps the issue by generating the certificate directly inside Docker at build time, meaning the private key only ever exists within the container and never touches the repository.

---

## AI Tools Used

- **Claude (Anthropic)** — To review code and improve wording
