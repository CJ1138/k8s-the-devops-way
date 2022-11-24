cat > ../../keys/service-account-csr.json <<EOF
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
  -ca=../../keys/ca.pem \
  -ca-key=../../keys/ca-key.pem \
  -config=../../keys/ca-config.json \
  -profile=kubernetes \
  ../../keys/service-account-csr.json | cfssljson -bare ../../keys/service-account