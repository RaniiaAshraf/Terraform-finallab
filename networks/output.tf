output "myvpcid" {
  value = aws_vpc.myvpc.id
}

output "securitygroupid" {
  value = aws_security_group.securitygroup.id
}

output "public-subnet-0" {
  value =  aws_subnet.publicsubnet[0].id

}
output "public-subnet-1" {
  value = aws_subnet.publicsubnet[1].id

}

output "private-subnet-1" {
  value = aws_subnet.privatesubnet[0].id

}
output "private-subnet-2" {
  value = aws_subnet.privatesubnet[1].id

}