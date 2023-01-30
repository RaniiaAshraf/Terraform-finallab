output "public-ec2-1" {
  value = aws_instance.public-ec2[0].id
}
output "public-ec2-2" {
  value = aws_instance.public-ec2[1].id
}

output "private-ec2-1" {
  value = aws_instance.private-ec2[0].id
}
output "private-ec2-2" {
  value = aws_instance.private-ec2[1].id
}