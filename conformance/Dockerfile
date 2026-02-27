FROM mcr.microsoft.com/dotnet/sdk:8.0

ARG GO_VERSION=1.22.8

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        python3 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tgz \
    && rm -rf /usr/local/go \
    && tar -C /usr/local -xzf /tmp/go.tgz \
    && rm -f /tmp/go.tgz

ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /workspace
COPY . .

CMD ["python3", "conformance/runner.py", "--adapters", "go,dotnet"]
