cat > ./keys/kube-proxy-csr.json <<EOF
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
  -ca=./keys/ca.pem \
  -ca-key=./keys/ca-key.pem \
  -config=./keys/ca-config.json \
  -profile=kubernetes \
  ./keys/kube-proxy-csr.json | cfssljson -bare ./keys/kube-proxy