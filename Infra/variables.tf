variable "cluster_name" {
  default = "tanu-poc-cluster"
}

variable "vpc_id" {
  default = "vpc-099554553cf568ba" # Your existing VPC
}

variable "subnet_ids" {
  default = [
    "subnet-04db4bef6e4c558a1", # ap-south-1a
    "subnet-0d085fcada6c3dc1a", # ap-south-1b
  ]
}