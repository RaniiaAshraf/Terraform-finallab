module "vpc"  {
    source = "./networks"
    vpc-cidr = "10.0.0.0/16"
    vpc-name = "terraform-vpc"

    igw-name = "terraform-internet-gate-way"

    nat-name = "terrform-nat"
    
    routepublic-cidr = "0.0.0.0/0"
    routepublic = "terraform-public-route-table" 
    routeprivate = "terraform-private-route-table"
    
    
    subnet-cidr = ["10.0.0.0/24","10.0.2.0/24"]
    subnet-name = ["terraform-public-subnet", "terraform-public-subnet-2"]
    zone = ["us-east-1a","us-east-1b"]

    subnetcidr-1= [ "10.0.1.0/24", "10.0.3.0/24"]
    subnetname1 = ["terraform-private-subnet", "terraform-private-subnet-2"]
    zone-2 = ["us-east-1a","us-east-1b"]

    security-group-name ="security-group-ssh-http"

}

# create 2 ec2 public and 2 ec2 private 
module "ec2" {
   source = "./EC2"
  
   ami-id = "ami-00874d747dde814fa" # ubuntu img
   securitygroupid = module.vpc.securitygroupid
   public-ec2-name = ["terraform-public-ec2","terraform-public-ec2-2"]
   public-subnet-id = [module.vpc.public-subnet-0, module.vpc.public-subnet-1]

   
   private-ec2-name = ["terraform-private-ec2","terraform-private-ec2-2"]
   private-subnet-id = [module.vpc.private-subnet-1, module.vpc.private-subnet-2]
   loadbalancer-dnsname = module.alb.loadbalancer2-dnsname

}

module "alb" {
   source = "./loadbalancer"
   loadbalancertarget-name = "public-alb-tg"
   loadbalancer-name = "terraform-public-alb"
   securitygroup-name = "terraform_alb_security_group"
   vpc-id = module.vpc.myvpcid
   public-subnet-id-1 = module.vpc.public-subnet-0
   public-subnet-id-2 = module.vpc.public-subnet-1
   publicinstance =  [module.ec2.public-ec2-1,module.ec2.public-ec2-2]

   private-loadbalancer-name = "terraform-private-alb"
   private-loadbalancer-targetname = "private-alb-tg"
   private-subnet-id-1 = module.vpc.private-subnet-1
   private-subnet-id-2 = module.vpc.private-subnet-2
   privateinstance = [module.ec2.private-ec2-1,module.ec2.private-ec2-2]
   
}


