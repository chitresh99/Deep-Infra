# SSH Protocol & Key-Based Authentication 

## **1. SSH Protocol Fundamentals**
SSH (Secure Shell) is a cryptographic network protocol for secure remote access and data communication over untrusted networks.

### **Core Components**
- **Transport Layer**: Establishes secure channel (encryption, integrity checks)
- **Authentication Layer**: Verifies client identity
- **Connection Layer**: Multiplexes multiple channels (shell, SFTP, port forwarding)

### **Key Security Features**
- Asymmetric encryption for key exchange (Diffie-Hellman)
- Symmetric encryption for session data (AES, ChaCha20)
- Message authentication codes (HMAC)
- Perfect Forward Secrecy (PFS)

## **2. SSH Key Pair Authentication**

### **Key Pair Components**
| Component | Location | Security Consideration |
|-----------|----------|-----------------------|
| Private Key | Client's `~/.ssh/id_algorithm` | Must NEVER be shared (600 permissions) |
| Public Key | Server's `~/.ssh/authorized_keys` | Can be freely distributed |

### **Key Types Comparison**
```bash
# Generate different key types
ssh-keygen -t ed25519 -a 100  # Best for modern systems
ssh-keygen -t ecdsa -b 521    # NIST-compliant
ssh-keygen -t rsa -b 4096      # Widely compatible
```

**Security Hierarchy**: Ed25519 > ECDSA > RSA

## **3. Key-Based Auth Workflow**
1. **Key Exchange**: Client initiates connection to port 22
2. **Server Identification**: Presents host key (`/etc/ssh/ssh_host_*`)
3. **Client Verification**: Checks against `known_hosts`
4. **Authentication**:
   - Client proves possession of private key
   - Server checks matching public key in `authorized_keys`
5. **Session Establishment**: Encrypted channel created

## **4. Advanced SSH Key Management**

### **Best Practices**
```bash
# Restrict key usage in authorized_keys:
from="192.168.1.*",command="/bin/backup.sh" ssh-ed25519 AAAA... 
```

**Security Enhancements**:
- Use `ssh-keygen -o` for new KDF format
- Implement certificate-based auth (`ssh-keygen -s`)
- Set key expiration: `-V +52w`

### **Key Rotation Process**
1. Generate new key pair
2. Add new public key to servers
3. Test connection
4. Remove old key from `authorized_keys`
5. Update CI/CD systems and automation

## **5. Enterprise SSH Considerations**

### **Centralized Management**
- **SSH Certificate Authority**: Scalable alternative to key distribution
- **Jump Hosts/Bastions**: Controlled access points
- **Session Recording**: Tools like Teleport, Gravitational

### **Compliance Requirements**
- FIPS 140-2 validated modules
- NIST SP 800-171 controls
- PCI DSS logging requirements

## **6. Troubleshooting Key Auth Issues**

### **Common Problems**
```bash
# Debug connection attempts
ssh -vvv user@host

# Check server logs
journalctl -u sshd --no-pager -n 50

# Verify permissions
stat -c "%a %n" ~/.ssh/*
```

**Permission Requirements**:
- `~/.ssh` → 700
- Private keys → 600
- `authorized_keys` → 644

## **8. Emerging Trends**
- **Quantum-Resistant Algorithms** (CRYSTALS-Kyber)
- **SSH over QUIC** (experimental)
- **Hardware-backed keys** (YubiKey, TPM)
- **Zero Trust SSH** (device attestation required)
