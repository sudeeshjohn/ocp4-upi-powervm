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

provider "openstack" {
  user_name   = var.user_name
  password    = var.password
  tenant_name = var.tenant_name
  domain_name = var.domain_name
  auth_url    = var.auth_url
  insecure    = var.insecure
}

resource "random_id" "label" {
  count       = var.cluster_id == "" ? 1 : 0
  byte_length = "2" # Since we use the hex, the word lenght would double
  prefix      = "${var.cluster_id_prefix}-"
}

locals {
  # Generates cluster_id as combination of cluster_id_prefix + (random_id or user-defined cluster_id)
  cluster_id   = var.cluster_id == "" ? random_id.label[0].hex : (var.cluster_id_prefix == "" ? var.cluster_id : "${var.cluster_id_prefix}-${var.cluster_id}")
  storage_type = lookup(var.bastion, "count", 1) > 1 ? "none" : var.storage_type
}

module "bastion" {
  source = "./modules/1_bastion"

  cluster_domain                  = var.cluster_domain
  cluster_id                      = local.cluster_id
  bastion                         = var.bastion
  bastion_port_ids                = module.network.bastion_port_ids
  scg_id                          = var.scg_id
  openstack_availability_zone     = var.openstack_availability_zone
  rhel_username                   = var.rhel_username
  private_key                     = local.private_key
  public_key                      = local.public_key
  create_keypair                  = local.create_keypair
  keypair_name                    = "${local.cluster_id}-keypair"
  ssh_agent                       = var.ssh_agent
  connection_timeout              = var.connection_timeout
  jump_host                       = var.jump_host
  rhel_subscription_username      = var.rhel_subscription_username
  rhel_subscription_password      = var.rhel_subscription_password
  rhel_subscription_org           = var.rhel_subscription_org
  rhel_subscription_activationkey = var.rhel_subscription_activationkey
  ansible_repo_name               = var.ansible_repo_name
  storage_type                    = local.storage_type
  volume_size                     = var.volume_size
  volume_storage_template         = var.volume_storage_template
  setup_squid_proxy               = var.setup_squid_proxy
  proxy                           = var.proxy
}

module "network" {
  source = "./modules/2_network"

  cluster_id              = local.cluster_id
  network_name            = var.network_name
  bastion                 = var.bastion
  network_type            = var.network_type
  sriov_vnic_failover_vfs = var.sriov_vnic_failover_vfs
  sriov_capacity          = var.sriov_capacity
}
