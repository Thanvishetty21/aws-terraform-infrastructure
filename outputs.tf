output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "web_public_ips" {
  description = "Public IPs of the web servers"
  value       = module.ec2.public_ips
}

output "web_urls" {
  description = "URLs to open in a browser"
  value       = [for ip in module.ec2.public_ips : "http://${ip}"]
}

output "rds_endpoint" {
  description = "RDS endpoint (reachable only from inside the VPC)"
  value       = module.rds.endpoint
}
