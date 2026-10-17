# spark-with-glue

Apache Spark Docker image that can use the AWS Glue Data Catalog as its Hive metastore.

Apache Spark can't use AWS Glue as a metastore out of the box. This image starts from the official [`apache/spark`](https://hub.docker.com/r/apache/spark) image and adds:

- the patched Hive 2 jars (`hive-common`, `hive-exec`) and the AWS Glue Data Catalog client, built by [aws-glue-data-catalog-spark-client](https://github.com/sdaberdaku/aws-glue-data-catalog-spark-client)
- `hadoop-aws`, the AWS SDK v2 bundle and the S3 Analytics Accelerator, for reading and writing S3 through S3A
- the AWS SDK v1 Glue, STS and core jars that the Glue client needs

## Images

Images are published to the GitHub Container Registry for `linux/amd64` and `linux/arm64`. Each tag matches the `apache/spark` base image it was built from:

| Tag | Spark | Scala | Java |
| --- | --- | --- | --- |
| `4.1.1-scala2.13-java21-python3-ubuntu` | 4.1.1 | 2.13 | 21 |
| `4.1.0-scala2.13-java21-python3-ubuntu` | 4.1.0 | 2.13 | 21 |
| `4.0.1-scala2.13-java21-python3-ubuntu` | 4.0.1 | 2.13 | 21 |
| `3.5.7-scala2.12-java17-python3-ubuntu` | 3.5.7 | 2.12 | 17 |

```sh
docker pull ghcr.io/sdaberdaku/spark-with-glue:4.1.1-scala2.13-java21-python3-ubuntu
```

## Usage

Enable Hive support and point the metastore client at Glue:

```sh
/opt/spark/bin/pyspark \
  --conf spark.sql.catalogImplementation=hive \
  --conf spark.hive.imetastoreclient.factory.class=com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory
```

The Glue client and S3A pick up credentials from the default AWS credentials chain (environment variables, an instance profile, or IRSA / EKS Pod Identity on Kubernetes).

The background and the full setup are in [Enabling AWS Glue support in Apache Spark 4](https://medium.com/towards-data-engineering/enabling-aws-glue-support-in-apache-spark-4-2c1fca7a7149).

## Building a new version

1. Update the `FROM` image and `SPARK_GLUE_CLIENT_TAG` in the `Dockerfile` to the new Spark version. A matching [Glue client release](https://github.com/sdaberdaku/aws-glue-data-catalog-spark-client/releases) must exist.
2. Commit, then push a git tag named after the base image tag (for example `4.1.1-scala2.13-java21-python3-ubuntu`).
3. The `build.yaml` workflow builds the multi-arch image, pushes it to `ghcr.io/sdaberdaku/spark-with-glue` under that tag, and attaches a build provenance attestation.

## License

[Apache License 2.0](LICENSE)
