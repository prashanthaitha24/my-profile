variable "zone_id"{type=string}
variable "records"{type=list(object({name=string,type=string,alias=object({name=string,hosted_zone_id=string,evaluate_target_health=bool})})) , default=[]}
