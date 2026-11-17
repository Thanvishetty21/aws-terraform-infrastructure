variable "name_prefix" { type = string }
variable "instance_type" { type = string }
variable "instance_count" { type = number }
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "key_name" { type = string }
variable "user_data_path" { type = string }
