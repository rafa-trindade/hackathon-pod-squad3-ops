# ==============================================================================
# SQUAD 3 - COMPUTE INSTANCE STRATEGY (OPS ENGINE)
# Objetivo: Provisionar a VM de processamento e orquestração (Airflow/Docker)
# ==============================================================================

resource "oci_core_instance" "airflow_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "squad3-airflow-engine"
  
  shape = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    display_name     = "squad3-vnic"
    assign_public_ip = true 
    hostname_label   = "airflow"
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_id 
    boot_volume_size_in_gbs = 150 
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("./scripts/cloud-init.sh"))
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}