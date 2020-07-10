# Chef roles that are shared across environment (aka not unique like tableau)
resource "chef_role" "controller" {
    name = "controller"
    run_list = [
        "recipe[fury]",
        "recipe[bifrost::controller]",
        "recipe[jarvis]",
        "recipe[romanoff]",
        "recipe[nebula]"
    ]
}

resource "chef_role" "controller_with_etcd" {
    name = "controller_with_etcd"
    run_list = [
        "recipe[fury]",
        "recipe[bifrost::controller]",
        "recipe[jarvis]",
        "recipe[romanoff]",
        "recipe[nebula]"
    ]
}

resource "chef_role" "worker" {
    name = "worker"
    run_list = [
        "recipe[fury]",
        "recipe[bifrost::worker]",
        "recipe[jarvis]",
        "recipe[romanoff]",
        "recipe[nebula]"
    ]
}

resource "chef_role" "etcd" {
    name = "etcd"
    run_list = [
        "recipe[fury]",
        "recipe[strange]",
        "recipe[jarvis]"
    ]
}
