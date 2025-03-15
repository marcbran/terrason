set fallback := true

default:
    @just --list

github:
    just -d .github -f .github/Justfile gen

github-debug:
    just -d .github -f .github/Justfile debug
