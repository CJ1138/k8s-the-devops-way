cat > ./scripts/keys/kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "UK",
      "L": "Manchester",
      "O": "system:kube-scheduler",
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
  ./scripts/keys/kube-scheduler-csr.json | cfssljson -bare ./scripts/keys/kube-scheduler