
test:
  @just -d pkg/terraform -f pkg/terraform/justfile test

build:
  @just -d pkg/terraform -f pkg/terraform/justfile build

push:
  @just -d pkg/terraform -f pkg/terraform/justfile push
