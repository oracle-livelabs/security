# Marketplace revision automation

marketplace_revision.sh manages the OCI Marketplace Publisher lifecycle for
the Deep Sec Local GenAI machine-image listing.

The script uses the existing listing, artifact, and Marketplace terms by
default. It avoids duplicate resources when an editable revision or matching
package already exists.

## Workflow

    cd marketplace

    # Read-only validation and status
    ./marketplace_revision.sh --action status

    # Preview the draft creation
    ./marketplace_revision.sh --action create-draft

    # Create the revision, upload the icon, and add the default package
    ./marketplace_revision.sh --action create-draft --execute

    # Submit after inspecting the printed revision OCID
    ./marketplace_revision.sh --action submit \
      --revision-id ocid1.mktpublistingrevision... --execute

After Marketplace Administration approves the revision, publish it privately:

    ./marketplace_revision.sh --action publish-private \
      --revision-id ocid1.mktpublistingrevision... --execute

With no --allowed-tenancy options, the script omits the allowlist, matching the
Deep Sec LiveLabs Marketplace procedure. To restrict access, add one or more
values:

    ./marketplace_revision.sh --action publish-private \
      --revision-id ocid1.mktpublistingrevision... \
      --allowed-tenancy ocid1.tenancy.oc1..example --execute

The current OCI CLI exposes a listing-revision icon upload command, but not a
banner-content upload command. The supplied banner is validated and reported
for console attachment; the script does not falsely treat it as uploaded.

## Required local tools

- OCI CLI 3.89.1 or later
- jq
- file
- An authenticated OCI CLI profile with Marketplace Publisher permissions

The default values are the current us-ashburn-1 listing, machine-image
artifact, and terms resources. Override them with the MARKETPLACE_* environment
variables when promoting a new image or listing.
