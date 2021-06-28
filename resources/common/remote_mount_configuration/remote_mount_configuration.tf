/*
    Excutes ansible playbook to configure remote mount between IBM Spectrum Scale compute and storage cluster.
*/

variable "turn_on" {}

resource "time_sleep" "wait_for_gui_db_initializion" {
  count           = tobool(var.turn_on) == true ? 1 : 0
  create_duration = "180s"
}
