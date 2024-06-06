# eth.limo on Oyster Proof of concept

Setup to deploy a barebone version of `eth.limo` service which includes [dweb-proxy-api](https://github.com/ethlimo/dweb-proxy-api), Caddy server, redis and IPFS node on Oyster. 

## Build an enclave image

Oyster deployments need the code and the setup to be packaged as an enclave image that implements low level networking and other utilities necessary to the code run within Oyster enclaves. To build the enclave image use

```sh
docker build -t enclave .
docker run -it --privileged -v `pwd`:/app/mount enclave
```

After running the above 2 commands, an `enclave` folder containing `enclave.eif` should be created. `enclave.eif` is the enclave image to be used for deployment.

Note: Current setup expects the environment used is `ARM64` and the deployment enclave will also be `ARM64`.

## Deploy on Oyster

Deploy on oyster by following the instructions in [docs](https://docs.marlin.org/user-guides/oyster/instances/quickstart/deploy). Once the enclave is deployed, please make a note of the IP address of the enclave.

## Test

To test the gateway use the following command

```sh
curl -k --resolve 'ens.eth:8443:<IP>' https://ens.eth:8443
```