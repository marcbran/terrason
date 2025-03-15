local providerDirs = [
  '/terraform-provider/providers/kreuzwerker/docker',
  '/terraform-provider/providers/hashicorp/archive',
  '/terraform-provider/providers/hashicorp/google',
  '/terraform-provider/providers/hashicorp/assert',
  '/terraform-provider/providers/hashicorp/tfmigrate',
  '/terraform-provider/providers/hashicorp/time',
  '/terraform-provider/providers/hashicorp/local',
  '/terraform-provider/providers/hashicorp/tls',
  '/terraform-provider/providers/hashicorp/null',
  '/terraform-provider/providers/hashicorp/azurerm',
  '/terraform-provider/providers/hashicorp/http',
  '/terraform-provider/providers/hashicorp/aws',
  '/terraform-provider/providers/hashicorp/external',
  '/terraform-provider/providers/hashicorp/random',
  '/terraform-provider/providers/hashicorp/kubernetes',
  '/terraform-provider/providers/hashicorp/dns',
  '/terraform-provider/providers/hashicorp/cloudinit',
  '/terraform-provider/providers/PagerDuty/pagerduty',
  '/terraform-provider/providers/logzio/logzio',
  '/terraform-provider/providers/grafana/grafana',
  '/terraform-provider/providers/integrations/github',
  '/terraform-provider/providers/DataDog/datadog',
  '/terraform-provider/providers/newrelic/newrelic',
  '/terraform-provider/providers/marcbran/jsonnet',
  '/terraform-provider/providers/marcbran/dolt',
];

{
  'dependabot.yml': std.manifestYamlDoc({
    version: 2,
    updates: [
      {
        'package-ecosystem': 'gomod',
        directory: '/terraform-provider/cmd/pull-provider',
        schedule: { interval: 'daily' },
      },
      {
        'package-ecosystem': 'github-actions',
        directory: '/',
        schedule: { interval: 'daily' },
      },
    ] + [
      {
        'package-ecosystem': 'terraform',
        directory: providerDir,
        schedule: { interval: 'daily' },
      }
      for providerDir in providerDirs
    ],
  }, indent_array_in_object=true, quote_keys=false),
}
