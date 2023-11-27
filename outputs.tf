################################################################
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2022
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################

output "bastion_ip" {
  value = join(", ", module.bastion.bastion_ip)
}

output "bastion_vip" {
  value = module.network.bastion_vip == "" ? null : module.network.bastion_vip
}

output "bastion_ssh_command" {
  value = "ssh ${var.rhel_username}@${module.network.bastion_vip == "" ? module.bastion.bastion_ip[0] : module.network.bastion_vip}"
}


