# Nginx Log Parser

A powerful Bash script for parsing, analyzing, and managing Nginx log files with Git integration.

## Features

- **Parse Nginx logs** into CSV format
- **Filter** logs by IP, status code, response time, or endpoint
- **Sort** logs by various criteria (request time, status code, body size, IP)
- **Analyze** request patterns and traffic statistics
- **Git integration** for version-controlled log storage

## Prerequisites

- Docker
- Git repository with access token
- Nginx log files

## Installation

1. Clone this repository or download the script files
2. Create a `.env` file with your Git credentials:

```env
GIT_REPO_URL=github.com/username/repository.git
GIT_TOKEN=your_github_token_here
GIT_USER=your_github_username
```

3. Build the Docker image:

```bash
docker build -t nginx-log-parser:latest .
```

## Usage

### Basic Command Structure

```bash
docker run --env-file .env \
  -v /path/to/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log [OPTION]
```

### Available Options

#### Convert to CSV

```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --plain
```

Converts the nginx log file to CSV format and saves it to `/git/nginx.csv`.

#### Get Unique IP Addresses

```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --get-ip
```

Lists all unique IP addresses from the log file.

#### Get Unique Endpoints

```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --get-endpoints
```

Lists all unique API endpoints accessed.

#### Store to Git Repository

```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --store
```

Pushes the generated CSV file to your Git repository. **Note:** You must generate the CSV file first using `--plain`.

### Filtering Options

#### Filter by IP Address

```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --filter by-ip 192.168.1.1
```

**Tip:** To see all available IP addresses in your log, first run `--get-ip` command.

#### Filter by Status Code

```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --filter by-status-code 404
```

#### Filter by Response Time

```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --filter by-response-time 0.5
```

#### Filter by Endpoint

```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --filter by-endpoint api
```

**Tip:** To see all available endpoints in your log, first run `--get-endpoints` command.

### Sorting Options

#### Sort by Request Time

```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --sort by-request-time
```

#### Sort by Status Code

```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --sort by-status-code
```

#### Sort by Body Size

```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --sort by-body-bytes
```

#### Sort by IP Address

```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --sort by-ip
```

### Statistics and Counting

#### Count Requests per IP

```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --count by-request
```

#### Sum Body Size per IP

```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --count by-body-size
```

## CSV Output Format

The generated CSV file contains the following columns:

1. `remote_addr` - Client IP address
2. `ident_id` - Identity ID
3. `username` - Username
4. `timestamp` - Request timestamp
5. `api_end` - API endpoint and HTTP method
6. `status_code` - HTTP status code
7. `body_size` - Response body size
8. `refer_page` - Referrer URL
9. `ua` - User agent string
10. `request_length` - Request length
11. `request_time` - Request processing time
12. `upstream_name` - Upstream server name
13. `upstream_addr` - Upstream server address
14. `fact_upstream_addr` - Actual upstream address
15. `resp_size` - Response size
16. `upstream_resp_time` - Upstream response time
17. `upstream_resp` - Upstream response
18. `trace_id` - Trace ID

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `GIT_REPO_URL` | Git repository URL (without https://) | `github.com/user/repo.git` |
| `GIT_TOKEN` | GitHub personal access token | `github_pat_11ABC...` |
| `GIT_USER` | GitHub username | `username` |
| `GIT_REPO_DIR` | Directory for Git operations (set in Dockerfile) | `/git` |

## File Structure

```
.
├── simple-script.sh    # Main parsing script
├── Dockerfile          # Docker configuration
├── .env               # Environment variables (create this)
└── README.md          # This file
```

## Workflow Example

### Basic Analysis Workflow

1. **First, explore your log data:**

Get all unique IP addresses:
```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --get-ip
```

Get all unique endpoints:
```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --get-endpoints
```

2. **Analyze traffic patterns:**

Count requests per IP:
```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --count by-request
```

3. **Filter interesting data:**

Based on the IP addresses you found, filter logs for a specific IP:
```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --filter by-ip 192.168.1.100
```

Or filter by endpoint you discovered:
```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --filter by-endpoint users
```

4. **Store results:**
```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --store
```

### Converting and Storing Workflow

1. Convert log to CSV:
```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --plain
```

2. Filter by status code:
```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --filter by-status-code 500
```

3. Store to Git:
```bash
docker run --env-file .env \
  -v /logs/nginx.log:/logs/nginx.log \
  -v /tmp/git:/git \
  nginx-log-parser:latest /logs/nginx.log --store
```

## Security Notes

- **Never commit your `.env` file** to version control
- Keep your GitHub token secure
- Use personal access tokens with minimal required permissions
- Consider using secret management tools for production environments

## Troubleshooting

### "File nginx.csv not found"
Make sure to run `--plain` before `--store` to generate the CSV file first.

### "Error: Missing required environment variables"
Verify your `.env` file contains all required variables: `GIT_REPO_URL`, `GIT_TOKEN`, `GIT_USER`.

### "Error: ip address should be valid"
Ensure the IP address follows the format `xxx.xxx.xxx.xxx` where each octet is 0-255.

### "Error: status code should be valid"
Status codes must be 3-digit numbers starting with 1-5 (e.g., 200, 404, 500).

