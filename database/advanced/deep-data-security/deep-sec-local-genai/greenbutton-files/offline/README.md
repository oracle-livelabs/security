# GreenButton offline runtime

This directory documents the wheelhouse pre-loaded in the custom image. The
Terraform cloud-init reads `/opt/deep-sec-offline/wheelhouse/py3.9` and installs the Admin
Console, Customer Sales App, Iceberg materializer, and Vibe CLI with pip's
`--no-index` and `--find-links` options. The GreenButton application archive
contains the source and Vibe CLI, but not the large wheelhouse.

The wheelhouse must be built for the custom image's `/usr/bin/python3` runtime
and the image architecture. Do not use the Jupyter Python 3.11 wheelhouse for
this stack. It must cover all declared runtime dependencies, including
`fastavro`, `pyiceberg[pyarrow,sql-sqlite]`, and `tomli` for Python 3.9. Stage
the wheels with:

```bash
  sudo env OFFLINE_ROOT=/home/opc/aiworld-offline/flask-python \
  TARGET_ROOT=/opt/deep-sec-offline \
  PYTHON_VERSION=3.9 \
  ./stage_greenbutton_offline_wheelhouse.sh
```

The package build refuses to create a GreenButton archive until at least one
Python 3.9 wheel is present. The deployment still needs the custom image's
system-provided Python 3.9 `venv`, `unzip`, `curl`, `wget`, `openssl`,
SQL*Plus, and Oracle Instant Client. Python packages are the part delivered by
this archive; OCI Object Storage and the database remain runtime services.
