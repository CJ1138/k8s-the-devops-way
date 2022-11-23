cat > ./scripts/keys/service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "UK",
      "L": "Manchester",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Greater Manchester"
    }
  ]
}
EOF

cfssl gencert \
  -ca=./scripts/keys/ca.pem \
  -ca-key=./scripts/keys/ca-key.pem \
  -config=./scripts/keys/ca-config.json \
  -profile=kubernetes \
  ./scripts/keys/service-account-csr.json | cfssljson -bare ./scripts/keys/service-account