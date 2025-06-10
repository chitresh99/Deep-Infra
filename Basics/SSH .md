# SSH

**SSH (Secure Shell)** is a cryptographic network protocol used for secure remote access and management of servers, devices, and systems over an unsecured network (like the internet).

Key Features:
* Encrypted Communication – Protects against eavesdropping.
* Authentication Methods – Password-based or key-based (more secure).
* Port 22 (Default) – Can be changed for security.

Used for:

Remote server access (ssh user@server-ip)

Secure file transfer (scp, sftp)

Git operations (git clone, git push over SSH)


## How SSH Works (Basic Flow)
Client connects to the server (ssh user@1.2.3.4).

Server sends its public key (stored in ~/.ssh/known_hosts).

Client verifies the server (checks if the key is trusted).

Authentication happens (password or SSH key).

Encrypted session starts (all commands/data are secure).


## SSH Key Authentication (Better Than Passwords)
Instead of passwords, prefer **SSH keys** (public-private key pairs).  

### **How SSH Keys Work:**  
- **Public Key** → Stored on the server (`~/.ssh/authorized_keys`).  
- **Private Key** → Stays securely on your machine (`~/.ssh/id_rsa`).  

### **Generating SSH Keys:**  
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```  
- `-t rsa` → Key type (RSA, Ed25519 also common).  
- `-b 4096` → Key length (stronger security).  

### **Copying Public Key to Server:**  
```bash
ssh-copy-id user@server-ip
```  
*(Or manually add `~/.ssh/id_rsa.pub` to `~/.ssh/authorized_keys` on the server.)*  

---

## **4. Common SSH Commands**  
| Command | Description |
|---------|-------------|
| `ssh user@server-ip` | Basic SSH login |
| `ssh -i ~/.ssh/key.pem user@server-ip` | Use a specific private key |
| `scp file.txt user@server-ip:/path/` | Securely copy files |
| `ssh -p 2222 user@server-ip` | Connect to a non-default port |
| `ssh -L 8080:localhost:80 user@server-ip` | Local port forwarding |
| `ssh -D 1080 user@server-ip` | SOCKS proxy (tunneling) |

---

## **5. Security Best Practices**  
🔒 **Disable Password Authentication** (use keys only):  
```bash
# In /etc/ssh/sshd_config:
PasswordAuthentication no
```  

🔒 **Change Default SSH Port** (reduces brute-force attacks):  
```bash
Port 2222  # Instead of 22
```  

🔒 **Use Fail2Ban** – Blocks brute-force attempts.  
🔒 **Restrict Users** – Allow only specific users to SSH:  
```bash
AllowUsers devopsuser
```  

---


Definition :
Eavesdropping is used by cyberattackers to intercept communication and steal sensitive data in transit

## Reference :

https://petal-estimate-4e9.notion.site/SSH-protocol-password-based-auth-1867dfd1073580c4a25ded92e1bdb842
