# Builder
FROM node:20-alpine as build

WORKDIR /build

COPY . .

WORKDIR /build

RUN apk update && \
    apk add \
        python3 \
        alpine-sdk \
        binutils-gold \
        linux-headers \
        git \
        wget \
        bash \
        ca-certificates && \
    # useradd -u 10005 dwebapi && \
    # tail -n 1 /etc/passwd >/etc/passwd.scratch && \
    npm install && \
    npm run build
RUN cd /build && \
    git clone https://github.com/ipfs/kubo.git && \
    wget -O go.tar.gz https://go.dev/dl/go1.22.4.linux-arm64.tar.gz && \
    rm -rf /usr/local/go && tar -C /usr/local -xzf go.tar.gz && \
    export PATH=$PATH:/usr/local/go/bin && \
    cd kubo && \
    make build

# base image
FROM redis:alpine3.18 as runtime

# install dependency tools
RUN apk add --no-cache net-tools iptables iproute2 wget ipset nodejs

# working directory
WORKDIR /app

# supervisord to manage programs
RUN wget -O supervisord http://public.artifacts.marlin.pro/projects/enclaves/supervisord_master_linux_arm64
RUN chmod +x supervisord

# proxy component inside the enclave to enable outgoing connections
RUN wget -O ip-to-vsock-raw-outgoing http://public.artifacts.marlin.pro/projects/enclaves/ip-to-vsock-raw-outgoing_v1.0.0_linux_arm64
RUN chmod +x ip-to-vsock-raw-outgoing

# proxy component inside the enclave to enable incoming connections
RUN wget -O vsock-to-ip-raw-incoming http://public.artifacts.marlin.pro/projects/enclaves/vsock-to-ip-raw-incoming_v1.0.0_linux_arm64
RUN chmod +x vsock-to-ip-raw-incoming

# key generator to generate static keys
RUN wget -O keygen http://public.artifacts.marlin.pro/projects/enclaves/keygen_v1.0.0_linux_arm64
RUN chmod +x keygen

# attestation server inside the enclave that generates attestations
RUN wget -O attestation-server http://public.artifacts.marlin.pro/projects/enclaves/attestation-server_v1.0.0_linux_arm64
RUN chmod +x attestation-server

# dnsproxy to provide DNS services inside the enclave
RUN wget -O dnsproxy http://public.artifacts.marlin.pro/projects/enclaves/dnsproxy_v0.46.5_linux_arm64
RUN chmod +x dnsproxy

# vsock http querier to query setup params
RUN wget -O vet http://public.artifacts.marlin.pro/projects/enclaves/vet_v1.0.0_linux_arm64
RUN chmod +x vet

# supervisord config
COPY supervisord.conf /etc/supervisord.conf

# setup.sh script that will act as entrypoint
COPY setup.sh ./
RUN chmod +x setup.sh

# your custom setup goes here
COPY --from=build --chown=10005:10005 /build/node_modules ./node_modules
COPY --from=build --chown=10005:10005 /build/package.json .
COPY --from=build --chown=10005:10005 /build/tsconfig.json .
COPY --from=build --chown=10005:10005 /build/dist ./dist
COPY --from=build /etc/ssl /etc/ssl
# COPY --from=build /etc/passwd.scratch /etc/passwd
COPY --from=build /build/entrypoint.sh .
RUN chmod +x /app/entrypoint.sh
RUN wget -O caddy "https://caddyserver.com/api/download?os=linux&arch=arm64"
RUN chmod +x /app/caddy
COPY --from=build /build/Caddyfile .
COPY --from=build /build/kubo/cmd/ipfs/ipfs .
RUN chmod +x /app/ipfs

# RUN mkdir -p /home/dwebapi
# RUN chown dwebapi: /home/dwebapi
# RUN chmod u+w /home/dwebapi

# USER dwebapi

# Node options to use openssl CA certificates
# ENV NODE_OPTIONS="--import=extensionless/register --use-openssl-ca"

# entry point
ENTRYPOINT [ "/app/setup.sh" ]