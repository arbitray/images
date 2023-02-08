# syntax = docker/dockerfile:1.4.0
FROM ubuntu:22.10 AS BUILDER

ARG VERSION=v4.41-9782-beta
ARG RELEASE_DATE=2022.11.17
ARG ARCH=x64-64bit

WORKDIR /build

RUN apt update && apt install -y gcc make wget

RUN wget https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/${VERSION}/softether-vpnserver-${VERSION}-${RELEASE_DATE}-linux-${ARCH}.tar.gz && \
    tar -xvf softether-vpnserver-${VERSION}-${RELEASE_DATE}-linux-${ARCH}.tar.gz && \
    cd vpnserver && \
    make

# syntax = docker/dockerfile:1.4.0
FROM ubuntu:22.10

WORKDIR /home/softethervpn

COPY --from=BUILDER /build/vpnserver /home/softethervpn/bin

RUN chown root:root -R /home/softethervpn/bin

USER root

EXPOSE 443 992 1194 5555 21450 32823 41116 44872

RUN echo '\
/home/softethervpn/bin/vpnserver start\n\
tail\n\
' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]
