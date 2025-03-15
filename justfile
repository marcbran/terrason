set fallback := true

default:
    @just --list

github:
    just -d .github -f .github/Justfile manifest

github-debug:
    just -d .github -f .github/Justfile debug

[no-cd]
jsonnet-release branch path="" source=".":
    #!/usr/bin/env bash
    branch="{{branch}}"
    path="{{path}}"
    source="{{source}}"

    if [[ "${path}" == "" ]]; then
      path="${branch}"
    fi

    rm -rf release
    git clone git@github.com:marcbran/jsonnet.git release

    pushd release
    git checkout "${branch}" || git checkout -b "${branch}"
    git pull
    popd

    mkdir -p "release/${path}"
    cp "${source}/main.libsonnet" "release/${path}/main.libsonnet"

    pushd release
    git add -A
    git commit -m "release ${path}"
    git push --set-upstream origin "${branch}"
    popd

    rm -rf release
