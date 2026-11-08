"""Drain only state-owned PoC log buckets, using bounded AWS CLI responses."""

import json
import subprocess
import sys
from pathlib import Path


def aws(*args):
    result = subprocess.run(
        ["aws", *args, "--region", "eu-west-1", "--output", "json"],
        check=True, capture_output=True, text=True,
    )
    return json.loads(result.stdout) if result.stdout.strip() else {}


def main():
    account = aws("sts", "get-caller-identity")["Account"]
    if account != "711695043680":
        raise RuntimeError("Unexpected AWS account")
    state = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    managed = [
        (resource["type"], instance["attributes"])
        for resource in state.get("resources", [])
        if resource["mode"] == "managed"
        for instance in resource.get("instances", [])
    ]
    allowed = {
        "byaku-cloudtrail-poc-711695043680",
        "byaku-awsconfig-poc-711695043680",
    }
    buckets = [a["id"] for kind, a in managed if kind == "aws_s3_bucket"]
    if set(buckets) - allowed:
        raise RuntimeError("State contains buckets outside the approved log bucket scope")
    # Stop the state-owned log writers before draining their versioned buckets.
    for kind, attributes in managed:
        if kind == "aws_cloudtrail":
            aws("cloudtrail", "stop-logging", "--name", attributes["arn"])
        elif kind == "aws_config_configuration_recorder":
            aws("configservice", "stop-configuration-recorder",
                "--configuration-recorder-name", attributes["name"])
    for bucket in buckets:
        deleted = 0
        while True:
            page = aws("s3api", "list-object-versions", "--bucket", bucket,
                       "--max-keys", "100", "--no-paginate")
            objects = [
                {"Key": item["Key"], "VersionId": item["VersionId"]}
                for item in page.get("Versions", []) + page.get("DeleteMarkers", [])
            ]
            if not objects:
                break
            result = aws("s3api", "delete-objects", "--bucket", bucket,
                         "--delete", json.dumps({"Objects": objects, "Quiet": True}))
            if result.get("Errors"):
                raise RuntimeError(f"Deletion failed in {bucket}: {result['Errors']}")
            deleted += len(objects)
        print(f"Emptied {bucket}: {deleted} versions and delete markers removed")


if __name__ == "__main__":
    main()
