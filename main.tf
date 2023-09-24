terraform {
  required_providers {
    unifi = {
      source  = "paultyng/unifi"
      version = "0.41.0"
    }
  }
  backend "azurerm" {
    key                  = "prod.terraform.tfstate"
    storage_account_name = "hometf"
    container_name       = "unifitf"
  }
}

provider "unifi" {
  allow_insecure = true
}

resource "unifi_network" "workhome" {
  name    = "workhome"
  purpose = "corporate"

  subnet       = "192.168.200.0/24"
  vlan_id      = 200
  dhcp_start   = "192.168.200.10"
  dhcp_stop    = "192.168.200.250"
  dhcp_dns     = ["192.168.1.1", "192.168.1.55"]
  dhcp_enabled = true
}

resource "unifi_network" "server" {
  name    = "server"
  purpose = "corporate"

  subnet       = "192.168.201.0/24"
  vlan_id      = 201
  dhcp_start   = "192.168.201.10"
  dhcp_stop    = "192.168.201.250"
  dhcp_dns     = ["192.168.1.1", "192.168.1.55"]
  dhcp_enabled = true
}

resource "unifi_network" "guestnetwork" {
  name    = "wifi-network-guest"
  purpose = "guest"

  subnet       = "192.168.101.0/24"
  vlan_id      = 101
  dhcp_start   = "192.168.101.10"
  dhcp_stop    = "192.168.101.200"
  dhcp_enabled = true
}

resource "unifi_wlan" "workhomewifi" {
  name       = var.HOMEWIFISSID
  passphrase = var.HOMEWIFIPASS
  security   = "wpapsk"

  network_id    = unifi_network.workhome.id
  user_group_id = data.unifi_user_group.default.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
}

resource "unifi_wlan" "guestwifi" {
  name       = var.GUESTWIFISSID
  passphrase = var.GUESTWIFIPASS
  security   = "wpapsk"
  is_guest   = true

  network_id    = unifi_network.guestnetwork.id
  user_group_id = data.unifi_user_group.default.id
  ap_group_ids  = [data.unifi_ap_group.default.id]
}

data "unifi_ap_group" "default" {
}

data "unifi_user_group" "default" {
}


resource "unifi_port_profile" "server" {
  name = "server"

  native_networkconf_id = unifi_network.server.id
}

resource "unifi_port_profile" "gaming" {
  name = "gaming"

  native_networkconf_id = unifi_network.workhome.id
}

resource "unifi_device" "udm" {
  name              = "UDM"
  forget_on_destroy = false

  port_override {
    number          = 1
    name            = "jnas"
    port_profile_id = unifi_port_profile.server.id
  }

  port_override {
    number          = 2
    name            = "jnuc"
    port_profile_id = unifi_port_profile.server.id
  }

  port_override {
    number          = 3
    name            = "gaming"
    port_profile_id = unifi_port_profile.gaming.id
  }

}
