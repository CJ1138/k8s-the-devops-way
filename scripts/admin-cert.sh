cat > ./scripts/keys/admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "UK",
      "L": "Manchester",
      "O": "system:masters",
      "OU": "Kubernetes The Hard Way",
      "ST": "Greater Manchster"
    }
  ]
}
EOF

cfssl gencert \
  -ca=./scripts/keys/ca.pem \
  -ca-key=./scripts/keys/ca-key.pem \
  -config=./scripts/keys/ca-config.json \
  -profile=kubernetes \
  ./scripts/keys/admin-csr.json | cfssljson -bare ./scripts/keys/admin