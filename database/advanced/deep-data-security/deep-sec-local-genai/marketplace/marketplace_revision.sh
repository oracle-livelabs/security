#!/usr/bin/env bash
# Repeatable OCI Marketplace Publisher workflow for the Deep Sec Local GenAI
# machine-image listing. Approval by Marketplace Administration is separate.

set -Eeuo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
PROJECT_DIR=$(cd -- "$SCRIPT_DIR/.." && pwd)

env_or_default() {
  local name="$1"
  local default_value="$2"
  local value
  value=$(printenv "$name" 2>/dev/null || true)
  if [[ -n "$value" ]]; then
    printf '%s\n' "$value"
  else
    printf '%s\n' "$default_value"
  fi
}

PROFILE=$(env_or_default OCI_CLI_PROFILE DEFAULT)
REGION=$(env_or_default OCI_CLI_REGION us-ashburn-1)
COMPARTMENT_ID=$(env_or_default MARKETPLACE_COMPARTMENT_ID ocid1.compartment.oc1..aaaaaaaauftuyo3bt7xrkvjzo7w6tnf2fh5cqbuaeur7gflh647teglifk4a)
LISTING_ID=$(env_or_default MARKETPLACE_LISTING_ID ocid1.mktpublisting.oc1.iad.amaaaaaaknuwtjiadqxmjvxhmk7brjjvyc3uok5adtycmiycg26pploojwxa)
ARTIFACT_ID=$(env_or_default MARKETPLACE_ARTIFACT_ID ocid1.mktpubartifact.oc1.iad.amaaaaaaknuwtjiaqlphverjm3zej2wqoq6u76wxw3il6jjmvstvhmjiltqa)
TERM_ID=$(env_or_default MARKETPLACE_TERM_ID ocid1.mktpubterm.oc1.iad.amaaaaaaknuwtjiaim4dpimgynup7rbrgikzoabnylv4r7vagh2swmtymheq)
DISPLAY_NAME=$(env_or_default MARKETPLACE_REVISION_DISPLAY_NAME "Deep Sec Local GenAI 1.0")
PACKAGE_VERSION=$(env_or_default MARKETPLACE_PACKAGE_VERSION 1.0)
ICON_PATH=$(env_or_default MARKETPLACE_ICON_PATH "$PROJECT_DIR/images/listing_icon-130px.png")
BANNER_PATH=$(env_or_default MARKETPLACE_BANNER_PATH "$PROJECT_DIR/images/deep-sec-local-genai-marketplace-banner.png")

ACTION=status
EXECUTE=0
REVISION_ID=
TENANCY_COUNT=0
ALLOWED_JSON='[]'

TITLE="Can Application Code or GenAI Bypass Oracle Deep Data Security?"
SHORT_DESCRIPTION="This workshop builds Oracle Deep Data Security on Oracle Autonomous AI Database. You create database end users, data roles, data grants, cross-table data grants, and an end user context. You then test those policies from the Customer Sales App and OCI Generative AI."
USAGE_INFORMATION="Use this BYOL LiveLabs image with the Deep Sec Local GenAI workshop. The image is intended for training and demonstration. Follow the workshop URL for setup, database configuration, and validation steps."
CONTENT_LANGUAGE='{"code":"en","name":"English"}'
SUPPORTED_LANGUAGES='[{"code":"en","name":"English"}]'
SUPPORT_CONTACTS='[{"name":"Oracle Database Security Product Management","email":"support@oracle.com","phone":"650-506-7000","subject":"Deep Data Security LiveLabs support"}]'
SUPPORT_LINKS='[{"name":"Workshop","url":"https://oracle-livelabs.github.io/security/database/advanced/workshops/desktop-deep-sec-local-genai/index.html"},{"name":"Oracle","url":"https://www.oracle.com"}]'
VERSION_DETAILS='{"description":"Deep Sec Local GenAI LiveLabs machine image and workshop.","number":"1.0","releaseDate":"2026-09-12"}'
PRODUCTS='[{"code":"database","categories":["SECURITY@DATABASE"]}]'
AVAILABILITY_AND_PRICING_POLICY="This BYOL listing is available in all markets. Customers must provide their own applicable software licenses. Infrastructure charges are billed separately by Oracle Cloud Infrastructure."

LONG_DESCRIPTION=$(cat <<'EOF'
The Stack starts with a working Customer Sales App and its ordinary Oracle objects. You create Marvin and Emma as local database end users. You build employee and manager data roles, then define row- and column-level access with data grants. Next, you extend those policies to Order History through a cross-table data grant. You also use an end user context to add manager access. At each stage, test the results with SQL queries and natural-language questions in Customer Insights. OCI Generative AI receives only the rows and columns that Oracle authorizes for the signed-in user. Changing the question cannot override or bypass database authorization.

- Create database end users, data roles, data grants, cross-table data grants, and end user context.
- Walk through Oracle Deep Data Security's core authorization capabilities and observe how each one changes the authorized result.
- Use OCI Generative AI to test natural-language queries against the data already authorized for the signed-in user.
- Verify that GenAI queries cannot override or bypass database authorizations.
EOF
)

usage() {
  cat <<'EOF'
Usage:
  marketplace_revision.sh --action status
  marketplace_revision.sh --action create-draft [--execute]
  marketplace_revision.sh --action submit --revision-id REVISION_OCID [--execute]
  marketplace_revision.sh --action publish-private --revision-id REVISION_OCID [--execute]

Actions:
  status          Read listing, artifact, terms, revisions, and packages.
  create-draft    Create or reuse the editable revision and default package.
  submit          Submit an existing revision for Marketplace review.
  publish-private Publish an approved revision privately. Without
                  --allowed-tenancy, the allowlist is omitted as specified by
                  the Deep Sec LiveLabs procedure.

Options:
  --execute                         Perform changes. Mutating actions otherwise
                                    print a dry-run summary.
  --revision-id OCID                Revision used by submit/publish-private.
  --allowed-tenancy OCID            Restrict private publication to one tenancy.
                                    Repeat for multiple tenancies.
  --profile NAME                    OCI CLI profile; default DEFAULT.
  --region NAME                     OCI region; default us-ashburn-1.
  --help                            Show this help.
EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

oci_cmd() {
  oci --profile "$PROFILE" --region "$REGION" "$@"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --action)
      [[ $# -ge 2 ]] || die "--action requires a value"
      ACTION="$2"
      shift 2
      ;;
    --execute)
      EXECUTE=1
      shift
      ;;
    --revision-id)
      [[ $# -ge 2 ]] || die "--revision-id requires a value"
      REVISION_ID="$2"
      shift 2
      ;;
    --allowed-tenancy)
      [[ $# -ge 2 ]] || die "--allowed-tenancy requires a value"
      ALLOWED_JSON=$(jq --arg tenancy "$2" '. + [$tenancy]' <<<"$ALLOWED_JSON")
      TENANCY_COUNT=$((TENANCY_COUNT + 1))
      shift 2
      ;;
    --profile)
      [[ $# -ge 2 ]] || die "--profile requires a value"
      PROFILE="$2"
      shift 2
      ;;
    --region)
      [[ $# -ge 2 ]] || die "--region requires a value"
      REGION="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

case "$ACTION" in
  status|create-draft|submit|publish-private) ;;
  *) die "unsupported action: $ACTION" ;;
esac

require_command oci
require_command jq
require_command file

listing_json() {
  oci_cmd marketplace-publisher listing get \
    --listing-id "$LISTING_ID" --output json
}

artifact_json() {
  oci_cmd marketplace-publisher artifact get \
    --artifact-id "$ARTIFACT_ID" --output json
}

term_json() {
  oci_cmd marketplace-publisher term get \
    --term-id "$TERM_ID" --output json
}

revisions_json() {
  oci_cmd marketplace-publisher listing-revision-collection \
    list-listing-revisions --listing-id "$LISTING_ID" \
    --compartment-id "$COMPARTMENT_ID" --all --output json
}

packages_json() {
  local revision_id="$1"
  oci_cmd marketplace-publisher listing-revision-package-collection \
    list-listing-revision-packages --listing-revision-id "$revision_id" \
    --compartment-id "$COMPARTMENT_ID" --all --output json
}

validate_inputs() {
  local listing artifact term
  listing=$(listing_json)
  artifact=$(artifact_json)
  term=$(term_json)

  [[ $(jq -r '.data."lifecycle-state"' <<<"$listing") == ACTIVE ]] ||
    die "listing is not ACTIVE"
  [[ $(jq -r '.data."listing-type"' <<<"$listing") == OCI_APPLICATION ]] ||
    die "listing is not OCI_APPLICATION"
  [[ $(jq -r '.data."package-type"' <<<"$listing") == MACHINE_IMAGE ]] ||
    die "listing package type is not MACHINE_IMAGE"
  [[ $(jq -r '.data.status' <<<"$artifact") == AVAILABLE ]] ||
    die "artifact is not AVAILABLE"
  [[ $(jq -r '.data."lifecycle-state"' <<<"$artifact") == ACTIVE ]] ||
    die "artifact is not ACTIVE"
  [[ $(jq -r '.data."lifecycle-state"' <<<"$term") == ACTIVE ]] ||
    die "terms resource is not ACTIVE"

  [[ -f "$ICON_PATH" ]] || die "icon file not found: $ICON_PATH"
  [[ $(file -b --mime-type "$ICON_PATH") == image/png ]] ||
    die "icon must be a PNG: $ICON_PATH"
  [[ -f "$BANNER_PATH" ]] || die "banner file not found: $BANNER_PATH"
}

resolve_revision_id() {
  if [[ -n "$REVISION_ID" ]]; then
    printf '%s\n' "$REVISION_ID"
    return
  fi

  jq -r --arg display_name "$DISPLAY_NAME" '
    [.data.items[] | select(."display-name" == $display_name)] |
    if length == 0 then "" else .[0].id end
  ' <<<"$(revisions_json)"
}

print_status() {
  validate_inputs
  echo "Listing:"
  listing_json | jq '.data | {id,name,"listing-type","package-type","lifecycle-state"}'
  echo "Artifact:"
  artifact_json | jq '.data | {id,"display-name","artifact-type",status,"lifecycle-state","validation-status"}'
  echo "Terms:"
  term_json | jq '.data | {id,name,"lifecycle-state"}'
  echo "Revisions:"
  revisions_json | jq '.data.items[] | {id,"display-name",status,"lifecycle-state","time-created"}'
}

create_or_reuse_revision() {
  local existing revision_json existing_status packages package_id
  existing=$(resolve_revision_id)

  if [[ -n "$existing" ]]; then
    revision_json=$(oci_cmd marketplace-publisher listing-revision get \
      --listing-revision-id "$existing" --output json)
    existing_status=$(jq -r '.data.status' <<<"$revision_json")
    case "$existing_status" in
      NEW|REJECTED)
        echo "Reusing editable revision $existing (status $existing_status)" >&2
        REVISION_ID="$existing"
        ;;
      *)
        die "revision $existing already exists with status $existing_status; use a new display name for a new revision"
        ;;
    esac
  else
    echo "No matching revision exists; creating $DISPLAY_NAME" >&2
    if (( ! EXECUTE )); then
      echo "DRY RUN: create OCI Application revision for listing $LISTING_ID" >&2
      echo "DRY RUN: upload icon $ICON_PATH" >&2
      echo "DRY RUN: create default package for artifact $ARTIFACT_ID" >&2
      echo "DRY RUN: banner is present at $BANNER_PATH; current CLI has no banner-content upload command" >&2
      return
    fi

    revision_json=$(oci_cmd marketplace-publisher listing-revision \
      create-listing-revision-create-oci-listing-revision-details \
      --listing-id "$LISTING_ID" \
      --headline "$TITLE" \
      --pricing-type BYOL \
      --products "$PRODUCTS" \
      --availability-and-pricing-policy "$AVAILABILITY_AND_PRICING_POLICY" \
      --display-name "$DISPLAY_NAME" \
      --tagline "Identity-aware authorization enforced by Oracle AI Database" \
      --keywords "Oracle AI Database,Deep Data Security,GenAI,BYOL,LiveLabs" \
      --short-description "$SHORT_DESCRIPTION" \
      --usage-information "$USAGE_INFORMATION" \
      --long-description "$LONG_DESCRIPTION" \
      --content-language "$CONTENT_LANGUAGE" \
      --supportedlanguages "$SUPPORTED_LANGUAGES" \
      --support-contacts "$SUPPORT_CONTACTS" \
      --support-links "$SUPPORT_LINKS" \
      --wait-for-state ACTIVE --max-wait-seconds 1200 \
      --output json)
    REVISION_ID=$(jq -r '.data.id' <<<"$revision_json")
    [[ -n "$REVISION_ID" && "$REVISION_ID" != null ]] ||
      die "revision creation returned no revision OCID"
    echo "Created revision: $REVISION_ID" >&2
  fi

  if (( EXECUTE )); then
    echo "Updating OCI Application pricing, product, availability, and version metadata" >&2
    oci_cmd marketplace-publisher listing-revision \
      update-listing-revision-update-oci-listing-revision-details \
      --listing-revision-id "$REVISION_ID" \
      --headline "$TITLE" \
      --tagline "Identity-aware authorization enforced by Oracle AI Database" \
      --keywords "Oracle AI Database,Deep Data Security,GenAI,BYOL,LiveLabs" \
      --short-description "$SHORT_DESCRIPTION" \
      --usage-information "$USAGE_INFORMATION" \
      --long-description "$LONG_DESCRIPTION" \
      --content-language "$CONTENT_LANGUAGE" \
      --supportedlanguages "$SUPPORTED_LANGUAGES" \
      --support-contacts "$SUPPORT_CONTACTS" \
      --support-links "$SUPPORT_LINKS" \
      --version-details "$VERSION_DETAILS" \
      --pricing-type BYOL \
      --products "$PRODUCTS" \
      --availability-and-pricing-policy "$AVAILABILITY_AND_PRICING_POLICY" \
      --is-rover-exportable false \
      --force --wait-for-state ACTIVE --max-wait-seconds 1200 >/dev/null
    echo "Uploading listing icon" >&2
    oci_cmd marketplace-publisher listing-revision \
      update-listing-revision-icon-content \
      --listing-revision-id "$REVISION_ID" \
      --update-listing-revision-icon-content "fileb://$ICON_PATH" \
      --wait-for-state ACTIVE --max-wait-seconds 1200 >/dev/null
  fi

  echo "NOTE: banner retained at $BANNER_PATH; current OCI CLI 3.89.1 exposes icon upload but no banner-content upload." >&2
  packages=$(packages_json "$REVISION_ID")
  package_id=$(jq -r --arg artifact_id "$ARTIFACT_ID" --arg version "$PACKAGE_VERSION" '
    [.data.items[] | select(."artifact-id" == $artifact_id and ."package-version" == $version)] |
    if length == 0 then "" else .[0].id end
  ' <<<"$packages")

  if [[ -n "$package_id" ]]; then
    echo "Reusing package: $package_id" >&2
  elif (( EXECUTE )); then
    package_id=$(oci_cmd marketplace-publisher listing-revision-package create \
      --listing-revision-id "$REVISION_ID" \
      --package-version "$PACKAGE_VERSION" \
      --artifact-id "$ARTIFACT_ID" \
      --term-id "$TERM_ID" \
      --are-security-upgrades-provided false \
      --display-name "Deep Sec Local GenAI machine image" \
      --description "BYOL machine image for the Deep Sec Local GenAI LiveLabs workshop." \
      --is-default true \
      --wait-for-state ACTIVE --max-wait-seconds 1200 \
      --query 'data.id' --raw-output)
    echo "Created package: $package_id" >&2
  else
    echo "DRY RUN: create package version $PACKAGE_VERSION using term $TERM_ID" >&2
  fi

  echo "Revision: $REVISION_ID"
}

submit_revision() {
  REVISION_ID=$(resolve_revision_id)
  [[ -n "$REVISION_ID" ]] || die "no revision found; pass --revision-id"

  local revision_json status package_count
  revision_json=$(oci_cmd marketplace-publisher listing-revision get \
    --listing-revision-id "$REVISION_ID" --output json)
  status=$(jq -r '.data.status' <<<"$revision_json")
  [[ "$status" == NEW || "$status" == REJECTED ]] ||
    die "revision $REVISION_ID cannot be submitted from status $status"

  package_count=$(packages_json "$REVISION_ID" | jq '.data.items | length')
  (( package_count > 0 )) || die "revision has no package"

  if (( EXECUTE )); then
    oci_cmd marketplace-publisher listing-revision \
      submit-listing-revision-for-review \
      --listing-revision-id "$REVISION_ID" \
      --note-details "Deep Sec Local GenAI BYOL machine image for Oracle Deep Data Security LiveLabs." \
      --should-auto-publish-on-approval false
    echo "Submitted revision $REVISION_ID for Marketplace review." >&2
  else
    echo "DRY RUN: submit revision $REVISION_ID with auto-publication disabled" >&2
  fi
  echo "Revision: $REVISION_ID"
}

publish_private() {
  REVISION_ID=$(resolve_revision_id)
  [[ -n "$REVISION_ID" ]] || die "pass --revision-id for publish-private"

  local revision_json status
  revision_json=$(oci_cmd marketplace-publisher listing-revision get \
    --listing-revision-id "$REVISION_ID" --output json)
  status=$(jq -r '.data.status' <<<"$revision_json")
  [[ "$status" == APPROVED || "$status" == UNPUBLISHED ]] ||
    die "revision $REVISION_ID cannot be privately published from status $status"

  if (( EXECUTE )); then
    if (( TENANCY_COUNT == 0 )); then
      echo "Publishing privately with no allowed-tenancies value, matching the LiveLabs procedure." >&2
      oci_cmd marketplace-publisher listing-revision \
        publish-listing-revision-as-private \
        --listing-revision-id "$REVISION_ID" \
        --wait-for-state SUCCEEDED --max-wait-seconds 1800
    else
      oci_cmd marketplace-publisher listing-revision \
        publish-listing-revision-as-private \
        --listing-revision-id "$REVISION_ID" \
        --allowed-tenancies "$ALLOWED_JSON" \
        --wait-for-state SUCCEEDED --max-wait-seconds 1800
    fi
    echo "Private publication request submitted for $REVISION_ID." >&2
  else
    echo "DRY RUN: publish revision $REVISION_ID as private" >&2
    if (( TENANCY_COUNT == 0 )); then
      echo "DRY RUN: omit --allowed-tenancies (broad LiveLabs procedure)" >&2
    fi
  fi
  echo "Revision: $REVISION_ID"
}

case "$ACTION" in
  status)
    print_status
    ;;
  create-draft)
    validate_inputs
    create_or_reuse_revision
    ;;
  submit)
    submit_revision
    ;;
  publish-private)
    publish_private
    ;;
esac
