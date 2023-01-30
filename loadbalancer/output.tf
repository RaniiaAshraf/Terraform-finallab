output "loadbalancer-dnsname" {
    value = aws_lb.loadbalancer.dns_name

}

output "loadbalancer2-dnsname" {
    value = aws_lb.loadbalancer-2.dns_name

}