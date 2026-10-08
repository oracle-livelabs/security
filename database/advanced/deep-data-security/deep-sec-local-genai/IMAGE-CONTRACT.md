# GreenButton custom image contract

GreenButton does not build the Compute image. The image is an external release
dependency and must be maintained separately from the application and
Terraform source.

## Current source expectations

| Contract item | Current expectation |
| --- | --- |
| Default region | `us-ashburn-1` |
| Default image | The `compute_image_ocid` default in `terraform-greenbutton/variables.tf` |
| Runtime Python | `/usr/bin/python3`, Python 3.9-compatible |
| Offline wheels | `/opt/deep-sec-offline/wheelhouse/py3.9` |
| Operating system | Oracle Linux 9-compatible for the supplied Instant Client installer |
| Database client | SQL*Plus and Oracle Instant Client available on `PATH`/library path |
| Required tools | `unzip`, `curl`, `wget`, `openssl`, `systemctl`, `sudo`, `runuser` |
| Jupyter | Preinstalled and managed by the service expected by cloud-init |
| Network | Private ADB reachability, Object Storage service gateway, and regional OCI Services Network access |
| Application model | GreenButton uses walletless TLS; the legacy wallet installer in the shared template is not the normal path |

The image must contain wheels for the Admin Console, Customer Sales App,
Iceberg materializer, and Vibe CLI. The declared runtime also requires the
`fastavro`, `pyiceberg[pyarrow,sql-sqlite]`, and `tomli` dependency families.
The application archive contains source and `vibe-cli.zip`; it deliberately does
not contain the large wheelhouse.

## Required image verification

Run these checks on the golden image or a disposable instance before publishing
a new image OCID:

```bash
cat /etc/os-release
/usr/bin/python3 --version
/usr/bin/python3 -m venv /tmp/deep-sec-image-venv
rm -rf /tmp/deep-sec-image-venv

test -d /opt/deep-sec-offline/wheelhouse/py3.9
find /opt/deep-sec-offline/wheelhouse/py3.9 -maxdepth 1 -type f -name '*.whl' | wc -l

command -v unzip
command -v curl
command -v wget
command -v openssl
command -v sqlplus
sqlplus -version

systemctl list-unit-files | grep -E 'jupyter|deep-sec' || true
```

The application dependency test must be performed without PyPI access:

```bash
python3 -m venv /tmp/deep-sec-wheel-test
/tmp/deep-sec-wheel-test/bin/python -m pip install \
  --no-index \
  --find-links=/opt/deep-sec-offline/wheelhouse/py3.9 \
  -r /path/to/greenbutton-files/flask-app/requirements.txt
/tmp/deep-sec-wheel-test/bin/python -m pip check
rm -rf /tmp/deep-sec-wheel-test
```

The Iceberg materializer has an additional dependency set. Verify it with the
same offline wheelhouse before replacing the image.

## Release metadata that still needs an owner

The following values should be filled in when the image process is formalized:

- image owner or team;
- image build repository and commit;
- image build date and version;
- image OCID for every supported region;
- CPU architecture;
- Python version and wheelhouse lock-file checksum;
- SQL*Plus and Instant Client versions;
- Jupyter service/version;
- security-patching and retirement policy;
- last successful GreenButton live-smoke-test date.

Do not silently change the Python minor version, architecture, Oracle client,
Jupyter service, or wheelhouse layout. Those are runtime compatibility changes
and require a package rebuild plus a live bootstrap test.

## Related source

- `greenbutton-files/offline/README.md`
- `prepare_deepsec_flask_offline.sh`
- `stage_greenbutton_offline_wheelhouse.sh`
- `terraform-greenbutton/variables.tf`
- `terraform-greenbutton/templates/genai-defaults-cloud-init.yaml.tftpl`
- `terraform-greenbutton/README.md`
