local providers = [
  'registry.terraform.io/kreuzwerker/docker',
  'registry.terraform.io/hashicorp/archive',
  'registry.terraform.io/hashicorp/google',
  'registry.terraform.io/hashicorp/assert',
  'registry.terraform.io/hashicorp/tfmigrate',
  'registry.terraform.io/hashicorp/time',
  'registry.terraform.io/hashicorp/local',
  'registry.terraform.io/hashicorp/tls',
  'registry.terraform.io/hashicorp/null',
  'registry.terraform.io/hashicorp/azurerm',
  'registry.terraform.io/hashicorp/http',
  'registry.terraform.io/hashicorp/aws',
  'registry.terraform.io/hashicorp/external',
  'registry.terraform.io/hashicorp/random',
  'registry.terraform.io/hashicorp/kubernetes',
  'registry.terraform.io/hashicorp/dns',
  'registry.terraform.io/hashicorp/cloudinit',
  'registry.terraform.io/PagerDuty/pagerduty',
  'registry.terraform.io/logzio/logzio',
  'registry.terraform.io/grafana/grafana',
  'registry.terraform.io/integrations/github',
  'registry.terraform.io/DataDog/datadog',
  'registry.terraform.io/newrelic/newrelic',
  'registry.terraform.io/marcbran/jsonnet',
  'registry.terraform.io/marcbran/dolt',
];

local directory = {
  'dependabot.yml': {
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
        directory: '/terraform-provider/providers/%s' % provider,
        schedule: { interval: 'daily' },
      }
      for provider in providers
    ],
  },
  workflows: {
    ['test-%s.yml' % std.strReplace(std.strReplace(provider, '/', '-'), '.', '-')]: {
      name: 'Test %s' % provider,
      on: {
        pull_request: {
          paths: ['terraform-provider/providers/%s/**' % provider],
        },
      },
      permissions: {
        contents: 'read',
      },
      jobs: {
        build: {
          name: 'Build',
          'runs-on': 'ubuntu-latest',
          'timeout-minutes': 5,
          steps: [
            {
              uses: 'actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683',
            },
            {
              uses: 'jaxxstorm/action-install-gh-release@v1.10.0',
              with: {
                repo: 'marcbran/jsonnet-kit',
              },
            },
            {
              name: 'Manifest Jsonnet files',
              run: 'jsonnet-kit -J ./terraform-provider/template/vendor manifest "./terraform-provider/providers/%s"' % provider,
            },
          ],
        },
      },
    }
    for provider in providers
  },
};

local manifestations = {
  '.yml'(data): std.manifestYamlDoc(data, indent_array_in_object=true, quote_keys=false),
};

{
  directory: directory,
  manifestations: manifestations,
}
