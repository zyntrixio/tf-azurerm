resource "chef_environment" "env" {
    name = azurerm_resource_group.rg.name

    default_attributes_json = jsonencode({
        "users" : {
            "sftp" : [
                {
                    "name" : "binktest",
                    "id" : 4000,
                    "ssh_key" : "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4hWtuYpNwLKB0YEHwxEdtib0oxDPWVfW9y45eJhfvcjQA8/e8GHHRCSIUsWEcmjEZE1ZHc1MX09xS1HteExxjhOtMJ1x5qS0ye0rbxGujkpxdyfuTfyU+MRIQI7r4/Gt1bsrEJyULz287mfZK+IePGRun9sbRxHcVqgTXnHy/7PdKUyzykLCvTcnCUT8pdRU8GNqAHwtNojMJ8Qa6g3FP6Q9rlYCMZ7gA+dJvkm6oxgkpss3nbi4ZiDfZVbsUG49k0TP6qBC0r404eJjKfES1PZ2RveFuwAw4rur0ctUwiEYZtbenv4EzaYNtIpFg569r5ubuGfNNu/LXnOS8CzV2Ol1qIq0wCFkS3HIvGzU8wp0Fv+7RYiJclNKnnxDQ2w/4batinNgyCqhenEIZSKCPfWDipQn4CEEGqjpKqGeI2kAJgEDDUXjAThUDJHG6ill0EXxvpw2Ae0Ua8vuUgwGqw5x8gwWvyHPRBTCgCekVofRwZHVtMzP72rD71zXkkhnst8EfVb6C/J629qeAl2kkQLUWReal5NTuTi4ZpTb4UFge97kjwtoYUncfU0aqepYn/h7nJI3CXXDkhz5oK20oo0nxpYmIkhBAHKN1OsyyIpb0cOZUgoqWlvbvKJjoaaKbcXiyWK+4AIAOkj0x7oCGGFGeTIhISvQp9WPIV4IsIw=="
                },
                {
                    "name" : "harveynichols",
                    "id" : 4001,
                    "ssh_key": "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEApo4pf1NWLWrcmRWqLvFKOvkzJKDyo8QkN/pil60x4YPs/j+8JUiO1UI9TeP4YSJ9C3nyFNkjqc0jorI5EnVUPdVCGRPweZCgr4Di4eu/2KgYobO9DzvRoBvZAzxIR3dlJDsnOa27FscQ6iZXWdgCvJcTPQaEot/8eKDifZ+eU3Rh2mpVCykiNH4qeYPUTJDws+aC1PfTQQ8bmcN8IWxcG+dVjkKzlM/NJ0lzsJiOQGRJc0ZuC66D8UwJXF0UEzsteWge9DDL394t9mHl5DFhhuLsZ+laNsqVstdppwFk+S9Hd63wy4Yrdu3Wz1obgXcBrdROESTyiZ5o4kaRwf48DQ==",
                },
                {
                    "name" : "iceland",
                    "id" : 4002,
                    "ssh_key" : "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAlR8IrClW5vyU3utv+LTshjt49FWxdHnogNj1JesWvQZPla0nFze28Ohup3EPWLZUbVL4z3ay8PJeotszIEDHKc5K8P2/cwytdopOpdvdWJfxZcLzIIrKSMXjc+uXWLA+jvav9JIewEda/SsiM2ChYmR6BtpQirUtupcrbXXPXsjWoZ1BZdKZ6EmVT3uq1bGvMUZgr77QThtbcfR4x9B/3eVJSK5r1H8baohnkQx0cEcCt9KSkjU3gw5RXGKqJXAci+nR/ieCNw5znqKHaIEvsV06UKxqL9UYjuXdLI1bA24R3IKxhb4vrklTt0paisXPljp4YekDRAJ7j9BpgSve3w==",
                },

            ]
        }
    })
}
