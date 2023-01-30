resource "aws_instance" "public-ec2" {
    count = length(var.public-ec2-name)
    tags = {
        Name = var.public-ec2-name[count.index]
    }
    key_name = "pair"
    ami = var.ami-id
    subnet_id = var.public-subnet-id[count.index]
    instance_type = "t2.micro"
    associate_public_ip_address = "true"  
    vpc_security_group_ids = [var.securitygroupid]
  
    provisioner "local-exec" {
        command = "echo ${var.public-ec2-name[count.index]} ${self.public_ip} >> ./all-ips.txt"
    
    }
    provisioner "local-exec" {
        command = "echo ${var.public-ec2-name[count.index]} ${self.private_ip} >> ./all-ips.txt"
      
    }
    provisioner "remote-exec" {
        inline =  ["sudo apt update -y",
        "sudo apt install -y nginx",
        "echo 'server { \n listen 80 default_server; \n  listen [::]:80 default_server; \n  server_name _; \n  location / { \n  proxy_pass http://${var.loadbalancer-dnsname}; \n  } \n}' > default",
        "sudo mv default /etc/nginx/sites-enabled/default",
        "sudo systemctl stop nginx",
        "sudo systemctl start nginx"
        ]
    }
    connection {
        type = "ssh"
        host = self.public_ip
        user = "ubuntu"
        private_key = file("./pair.pem")
        timeout = "4m"
    }

}


resource "aws_instance" "private-ec2" {
    count = length(var.private-ec2-name)
    tags = {
        Name = var.private-ec2-name[count.index]
    }
    ami =  var.ami-id
    subnet_id = var.private-subnet-id[count.index]
    instance_type = "t2.micro"
    associate_public_ip_address = "false"  
    vpc_security_group_ids = [var.securitygroupid]

    
    user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
    echo "hello private  " >/var/www/html/index.html
    EOF
    
}