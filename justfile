
test:
  @just -d pkg/terraform -f pkg/terraform/justfile test

push:
  @just -d pkg/terraform -f pkg/terraform/justfile push
