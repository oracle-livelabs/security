# Deep Sec Always Free IAM Verification

This archive verifies the IAM resources used by the regular Deep Sec Terraform
deployment without requiring its supplied custom Compute image. It is **not** a
replacement for the full Deep Sec lab: the Oracle Linux platform image does not
contain the application, JupyterLab, Vibe CLI, or database setup content.

The stack creates the same IAM resources as the regular archive:

- a Compute dynamic group matching this stack's exact instance OCID;
- a `generative-ai-chat` policy for that dynamic group;
- an Autonomous AI Database dynamic group and bucket-read policy;
- an isolated order-history uploader user, group, secret key, and bucket-write
  policy.

It uses an Always Free `VM.Standard.E2.1.Micro` Oracle Linux 8 platform image
and an Always Free Autonomous AI Database. Always Free availability is limited
to the tenancy home region and subject to OCI capacity and service availability.

## Deploy

1. Extract this ZIP before using it outside Resource Manager. Copy
   `terraform.tfvars.example` to `terraform.tfvars`, enter the tenancy,
   compartment, home region, SSH public key, and trusted IPv4 address.
2. Run `terraform init`, then `terraform plan` and confirm the planned IAM
   resources. The identity running Terraform needs tenancy permission to manage
   dynamic groups, policies, users, groups, memberships, and customer secret
   keys, in addition to the compartment-level resource permissions.
3. Run `terraform apply`.
4. In OCI Console or CLI, confirm both dynamic groups are `ACTIVE` and inspect
   the policy statements. The outputs give the instance OCID, ADB OCID, and
   created policy names.
5. Optionally make an instance-principal Generative AI chat call from the VM to
   prove effective authorization. That final step also needs a supported model
   and Generative AI access in the selected region.
6. Run `terraform destroy` after testing.

Do not expect the application URLs from the normal Deep Sec lab; this archive
does not start the application. The Terraform files are intentionally at the
ZIP root because Resource Manager uses that root as its working directory. The
archive pins Terraform 1.5.7 because the Resource Manager upload parser needs
the exact engine release, even though the Console labels it `1.5.x`.
