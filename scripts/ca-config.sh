#!/usr/bin/bash
cat > ./scripts/keys/ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ./scripts/keys/ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "UK",
      "L": "Manchester",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Greater Manchester"
    }
  ]
}
EOF

cfssl gencert -initca ./scripts/keys/ca-csr.json | cfssljson -bare ./scripts/keys/ca