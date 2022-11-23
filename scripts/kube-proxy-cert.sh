cat > ./scripts/keys/kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "UK",
      "L": "Manchester",
      "O": "system:node-proxier",
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
  ./scripts/keys/kube-proxy-csr.json | cfssljson -bare ./scripts/keys/kube-proxy