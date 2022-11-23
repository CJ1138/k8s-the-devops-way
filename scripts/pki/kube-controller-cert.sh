cat > ./keys/kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "UK",
      "L": "Manchester",
      "O": "system:kube-controller-manager",
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
  ./keys/kube-controller-manager-csr.json | cfssljson -bare ./keys/kube-controller-manager