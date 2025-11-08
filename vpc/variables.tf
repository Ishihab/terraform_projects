variable "subnets_A" {
  type = map(string)
  default = {
    "reserved" = "0"
    "web"      = "1"
    "app"      = "2"
    "db"       = "3"
  }
}

variable "subnets_B" {
  type = map(string)
  default = {
    "reserved" = "4"
    "web"      = "5"
    "app"      = "6"
    "db"       = "7"
  }
}
variable "subnets_C" {
  type = map(string)
  default = {
    "reserved" = "8"
    "web"      = "9"
    "app"      = "10"
    "db"       = "11"
  }
}

