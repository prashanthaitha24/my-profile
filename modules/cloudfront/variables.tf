variable "comment"{type=string,default="site-cdn"}
variable "s3_domain_name"{type=string}
variable "api_domain_name"{type=string,default=null}
variable "api_shared_secret"{type=string,default=null}
variable "price_class"{type=string,default="PriceClass_100"}
variable "aliases"{type=list(string),default=[]}
variable "enable_api_path"{type=bool,default=true}
variable "tags"{type=map(string),default={}}
