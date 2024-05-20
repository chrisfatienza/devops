graph TD;
  subgraph "AWS Region"
    subgraph "Web Servers"
      A[EC2 Instance 1] -->|Port 443| ALB[Application Load Balancer]
      B[EC2 Instance 2] -->|Port 443| ALB
    end
    subgraph "Load Balancer"
      ALB -->|443| TG[Target Group]
    end
    subgraph "MySQL Oracle Server"
      MYSQL[MySQL Oracle Server] -->|Replication| MYSQL2[MySQL Oracle Server 2]
    end
    ALB -->|Database Connection| MYSQL
  end
