# ==============================================================================
# SQUAD 3 - COMPUTE INSTANCE STRATEGY (OPS ENGINE)
# Objetivo: Provisionar a VM de processamento e orquestração (Airflow/Docker)
# ==============================================================================

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "latest_ubuntu" { 
  compartment_id         = var.compartment_id
  operating_system         = "Canonical Ubuntu" 
  operating_system_version = "22.04"         
  shape                    = "VM.Standard.E3.Flex"

  sort_by  = "TIMECREATED"
  sort_order = "DESC"
}

# --- CORE AIRFLOW VM ---
resource "oci_core_instance" "airflow_instance" {
  depends_on = [oci_core_subnet.public_subnet]

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "squad3-core-engine"
  
  shape = "VM.Standard.E3.Flex"

  shape_config {
    ocpus         = 4  
    memory_in_gbs = 32
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    display_name     = "squad3-vnic"
    assign_public_ip = true
    hostname_label   = "squad3"
  }

  source_details {
    source_type = "image"
    source_id = data.oci_core_images.latest_ubuntu.images[0].id
    boot_volume_size_in_gbs = 200 
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("${path.module}/scripts/cloud-init.sh"))
  }

  lifecycle {
    create_before_destroy = true
  }
}
