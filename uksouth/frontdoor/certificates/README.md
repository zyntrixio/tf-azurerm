# Filename
Certificates get loaded into the KeyVault being split on a `.` character. You must name things with alternative characters as the `.pfx` is stripped from the end of the string to generate the certificate name in the keyvault.

# File Type
Each certificate must be a pfx file, I converted a pem file to pfx with the below:

```
openssl pkcs12 -export -out output.pfx -inkey key.pem -in ca.pem -in cert.pem
```

When prompted for a password, leave it blank
