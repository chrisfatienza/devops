graph TD;
  subgraph "Internet"
    Users[Users]
  end
  
  subgraph "Primary AWS Region"
    subgraph "Web Servers"
      A[EC2 Instance 1] -->|Port 443| ALB[Application Load Balancer]
      B[EC2 Instance 2] -->|Port 443| ALB
    end
    subgraph "Load Balancer"
      ALB -->|443| TG[Target Group]
    end
    subgraph "AWS Shield"
      SHIELD[Shield Protection]
    end
    ALB -->|DDoS Protection| SHIELD
    subgraph "AWS WAF"
      WAF[WAF Rules]
    end
    ALB -->|Web Application Firewall| WAF
    subgraph "MySQL Oracle Server"
      MYSQL[MySQL Oracle Server] -->|Replication| MYSQL2[MySQL Oracle Server 2]
    end
    ALB -->|Database Connection| MYSQL
    subgraph "Route 53 (Primary)"
      Route53_Primary[Route 53]
      Route53_Primary --TCP/443 --> ALB
    end
  end
  
  subgraph "Backup AWS Region"
    subgraph "Web Servers (Backup)"
      C[EC2 Instance 1] -->|Port 443| ALB2[Application Load Balancer]
      D[EC2 Instance 2] -->|Port 443| ALB2
    end
    subgraph "Load Balancer (Backup)"
      ALB2 -->|443| TG2[Target Group]
    end
    subgraph "AWS Shield (Backup)"
      SHIELD_B[Shield Protection]
    end
    ALB2 -->|DDoS Protection| SHIELD_B
    subgraph "AWS WAF (Backup)"
      WAF_B[WAF Rules]
    end
    ALB2 -->|Web Application Firewall| WAF_B
    subgraph "MySQL Oracle Server (Backup)"
      MYSQL_B[MySQL Oracle Server Backup] -->|Replication| MYSQL2_B[MySQL Oracle Server 2 Backup]
    end
    ALB2 -->|Database Connection| MYSQL_B
    subgraph "Route 53 (Backup)"
      Route53_Backup[Route 53]
      Route53_Backup --TCP/443 --> ALB2
    end
  end
  Users --> Route53_Primary
