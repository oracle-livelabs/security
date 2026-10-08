# Deep Sec shared Iceberg publisher

This is a maintainer-only Terraform package. It creates one durable public-read
Object Storage bucket and one OCI Data Flow application. It never submits a
Data Flow run during `terraform apply`.

## Publish once

1. Set `tenancy_ocid`, `compartment_ocid`, and the existing Oracle-SSO operator
   group name in `terraform.tfvars`.
2. Apply this package.
3. Copy the `submit_command` output and run it once. Wait for `SUCCEEDED`.
4. Use an ADB test database to create an external table from `metadata_url` and
   prove `SELECT COUNT(*)` returns 1500.
5. Give GreenButton the `metadata_url`, `raw_files_read_par_url`, and
   `metadata_read_par_url` outputs.

The bucket has `prevent_destroy` because it is shared infrastructure. Remove
that lifecycle guard only through a deliberate retirement change.
