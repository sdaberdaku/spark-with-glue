# spark-with-glue

Apache Spark Docker image that can use the AWS Glue Data Catalog as its Hive metastore.

Apache Spark can't use AWS Glue as a metastore out of the box. This image starts from the official [`apache/spark`](https://hub.docker.com/r/apache/spark) image and adds:

- the patched Hive 2 jars (`hive-common`, `hive-exec`) and the AWS Glue Data Catalog client, built by [aws-glue-data-catalog-spark-client](https://github.com/sdaberdaku/aws-glue-data-catalog-spark-client)
- `hadoop-aws`, the AWS SDK v2 bundle, `wildfly-openssl` and, from Hadoop 3.4.2 (Spark 4.1.0) onward, the S3 Analytics Accelerator, for reading and writing S3 through S3A. The 3.5.7 and 4.0.1 images don't include these.
- the AWS SDK v1 Glue, STS and core jars that the Glue client needs (the 3.5.7 and 4.0.1 images ship the full AWS SDK v1 bundle instead)

## Images

Images are published to the GitHub Container Registry for `linux/amd64` and `linux/arm64`. Each tag matches the `apache/spark` base image it was built from:

| Tag | Spark | Scala | Java |
| --- | --- | --- | --- |
| `4.2.0-scala2.13-java21-python3-ubuntu` | 4.2.0 | 2.13 | 21 |
| `4.1.3-scala2.13-java21-python3-ubuntu` | 4.1.3 | 2.13 | 21 |
| `4.1.2-scala2.13-java21-python3-ubuntu` | 4.1.2 | 2.13 | 21 |
| `4.1.1-scala2.13-java21-python3-ubuntu` | 4.1.1 | 2.13 | 21 |
| `4.1.0-scala2.13-java21-python3-ubuntu` | 4.1.0 | 2.13 | 21 |
| `4.0.2-scala2.13-java21-python3-ubuntu` | 4.0.2 | 2.13 | 21 |
| `4.0.1-scala2.13-java21-python3-ubuntu` | 4.0.1 | 2.13 | 21 |
| `3.5.7-scala2.12-java17-python3-ubuntu` | 3.5.7 | 2.12 | 17 |

`latest` points to the most recently pushed tag, currently `4.2.0-scala2.13-java21-python3-ubuntu`.

```sh
docker pull ghcr.io/sdaberdaku/spark-with-glue:4.2.0-scala2.13-java21-python3-ubuntu
```

## Usage

Enable Hive support and point the metastore client at Glue:

```sh
/opt/spark/bin/pyspark \
  --conf spark.sql.catalogImplementation=hive \
  --conf spark.hive.imetastoreclient.factory.class=com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory \
  --conf spark.hadoop.aws.region=eu-central-1
```

The Glue client and S3A pick up credentials from the default AWS credentials chain (environment variables, an instance profile, or IRSA / EKS Pod Identity on Kubernetes). The Glue client reads its region from `spark.hadoop.aws.region`.

If the Glue catalog has no `default` database, the Glue client tries to create one when it starts. It can't be turned off, but if the call fails (for example without `glue:CreateDatabase` permission) the client logs an error and carries on. Spark also creates `default` when it's missing, unless `spark.sql.catalog.spark_catalog.defaultDatabase` names an existing database.

The background and the full setup are in [Enabling AWS Glue support in Apache Spark 4](https://medium.com/towards-data-engineering/enabling-aws-glue-support-in-apache-spark-4-2c1fca7a7149).

## Building a new version

1. Update the `FROM` image and `SPARK_GLUE_CLIENT_TAG` in the `Dockerfile` to the new Spark version. A matching [Glue client release](https://github.com/sdaberdaku/aws-glue-data-catalog-spark-client/releases) must exist.
2. Set `HADOOP_VERSION` to the Hadoop version that Spark release bundles (`hadoop.version` in Spark's `pom.xml`). Set `AWS_JAVA_SDK2_VERSION`, `S3_ANALYTICS_ACCELERATOR_VERSION` and `WILDFLY_OPENSSL_VERSION` to the versions that `hadoop-aws` release depends on (listed in the `hadoop-project` pom of the same version).
3. Commit, then push a git tag named after the base image tag (for example `4.2.0-scala2.13-java21-python3-ubuntu`). Every tag push also moves `latest`, so when releasing several versions push the tags oldest first and wait for each build to finish.
4. The `build.yaml` workflow builds the multi-arch image, pushes it to `ghcr.io/sdaberdaku/spark-with-glue` under that tag, and attaches a build provenance attestation.

## License

[Apache License 2.0](LICENSE)
