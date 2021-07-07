variable "region"{
    default = "ap-south-1"
    type = string
}
variable "profile"{
    default = "default"
    type = string
}
variable "range"{
    default = "10.0.0.0/16"
    type = string
}
variable "vpctag"{
    default = "clustervpc"
    type = string
}
variable "subrange"{
    default = "10.0.1.0/24"
    type = string
}
variable "zones"{
    default = "ap-south-1a"
    type = string
}
variable "subnettag"{
    default = "publicsubnet"
    type = string
}
variable "igtag"{
    default = "cluster_gateway"
    type = string
}
variable "rtag"{
    default = "main_rt"
    type = string
}
variable "sgname"{
    default = "cluster_sg"
    type = string
}
variable "amiid"{
    default = "ami-0c1a7f89451184c8b"
    type = string
}
variable "ec2type"{
    default = "t2.medium"
    type = string
}
variable "keyname"{
    default = "kruparaju"
    type = string
}
variable "k8_master"{
    default = "masternode"
    type = string
}
