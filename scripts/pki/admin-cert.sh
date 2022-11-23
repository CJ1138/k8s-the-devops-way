cat > ./keys/admin-csr.json <<EOF
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
  -ca=./keys/ca.pem \
  -ca-key=./keys/ca-key.pem \
  -config=./keys/ca-config.json \
  -profile=kubernetes \
  ./keys/admin-csr.json | cfssljson -bare ./keys/admin