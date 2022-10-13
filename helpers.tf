# This file is for ugly blocks of Code that need to be repeated to
# make other config cleaner

locals {
    private_dns = {
        root_defaults = {
            resource_group = module.uksouth-dns.dns_zones.resource_group.name
            primary_zone = module.uksouth-dns.dns_zones.bink_host.root.name
            secondary_zones = [
                module.uksouth-dns.dns_zones.bink_host.prod.name,
                module.uksouth-dns.dns_zones.bink_host.staging.name,
                module.uksouth-dns.dns_zones.bink_host.sandbox.name,
                module.uksouth-dns.dns_zones.bink_host.dev.name,
                module.uksouth-dns.dns_zones.bink_host.core.name,
            ]
        }
        core_defaults = {
            resource_group = module.uksouth-dns.dns_zones.resource_group.name
            primary_zone = module.uksouth-dns.dns_zones.bink_host.core.name
            secondary_zones = [
                module.uksouth-dns.dns_zones.bink_host.root.name,
                module.uksouth-dns.dns_zones.bink_host.prod.name,
                module.uksouth-dns.dns_zones.bink_host.staging.name,
                module.uksouth-dns.dns_zones.bink_host.sandbox.name,
                module.uksouth-dns.dns_zones.bink_host.dev.name,
            ]
        }
        prod_defaults = {
            resource_group = module.uksouth-dns.dns_zones.resource_group.name
            primary_zone = module.uksouth-dns.dns_zones.bink_host.prod.name
            secondary_zones = [
                module.uksouth-dns.dns_zones.bink_host.root.name,
                module.uksouth-dns.dns_zones.bink_host.staging.name,
                module.uksouth-dns.dns_zones.bink_host.sandbox.name,
                module.uksouth-dns.dns_zones.bink_host.dev.name,
                module.uksouth-dns.dns_zones.bink_host.core.name,
            ]
        }
        staging_defaults = {
            resource_group = module.uksouth-dns.dns_zones.resource_group.name
            primary_zone = module.uksouth-dns.dns_zones.bink_host.staging.name
            secondary_zones = [
                module.uksouth-dns.dns_zones.bink_host.root.name,
                module.uksouth-dns.dns_zones.bink_host.prod.name,
                module.uksouth-dns.dns_zones.bink_host.sandbox.name,
                module.uksouth-dns.dns_zones.bink_host.dev.name,
                module.uksouth-dns.dns_zones.bink_host.core.name,
            ]
        }
        dev_defaults = {
            resource_group = module.uksouth-dns.dns_zones.resource_group.name
            primary_zone = module.uksouth-dns.dns_zones.bink_host.dev.name
            secondary_zones = [
                module.uksouth-dns.dns_zones.bink_host.root.name,
                module.uksouth-dns.dns_zones.bink_host.prod.name,
                module.uksouth-dns.dns_zones.bink_host.sandbox.name,
                module.uksouth-dns.dns_zones.bink_host.staging.name,
                module.uksouth-dns.dns_zones.bink_host.core.name,
            ]
        }
        sandbox_defaults = {
            resource_group = module.uksouth-dns.dns_zones.resource_group.name
            primary_zone = module.uksouth-dns.dns_zones.bink_host.sandbox.name
            secondary_zones = [
                module.uksouth-dns.dns_zones.bink_host.root.name,
                module.uksouth-dns.dns_zones.bink_host.prod.name,
                module.uksouth-dns.dns_zones.bink_host.dev.name,
                module.uksouth-dns.dns_zones.bink_host.staging.name,
                module.uksouth-dns.dns_zones.bink_host.core.name,
            ]
        }
    }
    aks_dns = {
        root_defaults = {
            private = {
                resource_group = module.uksouth-dns.dns_zones.resource_group.name
                primary_zone = module.uksouth-dns.dns_zones.bink_host.root.name
                secondary_zones = local.private_dns.root_defaults.secondary_zones
            }
            public = {
                resource_group = module.uksouth-dns.dns_zones.resource_group.name
                name = module.uksouth-dns.dns_zones.bink_sh.root.name
            }
        }
        core_defaults = {
            private = {
                resource_group = module.uksouth-dns.dns_zones.resource_group.name
                primary_zone = module.uksouth-dns.dns_zones.bink_host.core.name
                secondary_zones = local.private_dns.core_defaults.secondary_zones
            }
            public = {
                resource_group = module.uksouth-dns.dns_zones.resource_group.name
                name = module.uksouth-dns.dns_zones.bink_sh.root.name
            }
        }
        prod_defaults = {
            private = {
                resource_group = module.uksouth-dns.dns_zones.resource_group.name
                primary_zone = module.uksouth-dns.dns_zones.bink_host.prod.name
                secondary_zones = local.private_dns.prod_defaults.secondary_zones
            }
            public = {
                resource_group = module.uksouth-dns.dns_zones.resource_group.name
                name = module.uksouth-dns.dns_zones.bink_sh.root.name
            }
        }
        staging_defaults = {
            private = {
                resource_group = module.uksouth-dns.dns_zones.resource_group.name
                primary_zone = module.uksouth-dns.dns_zones.bink_host.staging.name
                secondary_zones = local.private_dns.staging_defaults.secondary_zones
            }
            public = {
                resource_group = module.uksouth-dns.dns_zones.resource_group.name
                name = module.uksouth-dns.dns_zones.bink_sh.root.name
            }
        }
        dev_defaults = {
            private = {
                resource_group = module.uksouth-dns.dns_zones.resource_group.name
                primary_zone = module.uksouth-dns.dns_zones.bink_host.dev.name
                secondary_zones = local.private_dns.dev_defaults.secondary_zones
            }
            public = {
                resource_group = module.uksouth-dns.dns_zones.resource_group.name
                name = module.uksouth-dns.dns_zones.bink_sh.root.name
            }
        }
        sandbox_defaults = {
            private = {
                resource_group = module.uksouth-dns.dns_zones.resource_group.name
                primary_zone = module.uksouth-dns.dns_zones.bink_host.sandbox.name
                secondary_zones = local.private_dns.sandbox_defaults.secondary_zones
            }
            public = {
                resource_group = module.uksouth-dns.dns_zones.resource_group.name
                name = module.uksouth-dns.dns_zones.bink_sh.root.name
            }
        }
    }
}
