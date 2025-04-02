local terraformProviderManifest = import '../../../../template/main.libsonnet';
local provider = import 'provider.json';
terraformProviderManifest(provider)
