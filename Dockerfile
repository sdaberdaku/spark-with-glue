FROM apache/spark:4.1.0-scala2.13-java21-python3-ubuntu

ARG SPARK_GLUE_CLIENT_URL="https://github.com/sdaberdaku/aws-glue-data-catalog-spark-client"
ARG MAVEN_REPO_URL="https://repo1.maven.org/maven2"
ARG SPARK_GLUE_CLIENT_TAG="v4.1.0"
ARG HIVE2_VERSION=2.3.10
ARG HADOOP_VERSION=3.4.2
# The AWS Java SDK version 1.12.x is required by the AWS Glue Data Catalog Spark Client
ARG AWS_JAVA_SDK_VERSION=1.12.720
ARG AWS_JAVA_SDK2_VERSION=2.29.52
ARG S3_ANALYTICS_ACCELERATOR_VERSION=1.2.1
ARG WILDFLY_OPENSSL_VERSION=2.1.4.Final
ARG PY4J_VERSION=0.10.9.9

ENV SPARK_HOME=/opt/spark
ENV PYTHONPATH="${SPARK_HOME}/python/lib/py4j-${PY4J_VERSION}-src.zip:${SPARK_HOME}/python/lib/pyspark.zip"

# wget must overwrite the existing hive-common-*.jar and hive-exec-*-core.jar files with the patched ones.
RUN wget --quiet -O "${SPARK_HOME}/jars/hive-common-${HIVE2_VERSION}.jar" "${SPARK_GLUE_CLIENT_URL}/releases/download/${SPARK_GLUE_CLIENT_TAG}/hive-common-${HIVE2_VERSION}.jar" && \
    wget --quiet -O "${SPARK_HOME}/jars/hive-exec-${HIVE2_VERSION}-core.jar" "${SPARK_GLUE_CLIENT_URL}/releases/download/${SPARK_GLUE_CLIENT_TAG}/hive-exec-${HIVE2_VERSION}-core.jar" && \
    wget --quiet -P "${SPARK_HOME}/jars/" "${SPARK_GLUE_CLIENT_URL}/releases/download/${SPARK_GLUE_CLIENT_TAG}/aws-glue-datacatalog-spark-client.jar" && \
    wget --quiet -P "${SPARK_HOME}/jars/" "${MAVEN_REPO_URL}/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar" && \
    wget --quiet -P "${SPARK_HOME}/jars/" "${MAVEN_REPO_URL}/software/amazon/awssdk/bundle/${AWS_JAVA_SDK2_VERSION}/bundle-${AWS_JAVA_SDK2_VERSION}.jar" && \
    wget --quiet -P "${SPARK_HOME}/jars/" "${MAVEN_REPO_URL}/software/amazon/s3/analyticsaccelerator/analyticsaccelerator-s3/${S3_ANALYTICS_ACCELERATOR_VERSION}/analyticsaccelerator-s3-${S3_ANALYTICS_ACCELERATOR_VERSION}.jar" && \
    wget --quiet -P "${SPARK_HOME}/jars/" "${MAVEN_REPO_URL}/org/wildfly/openssl/wildfly-openssl/${WILDFLY_OPENSSL_VERSION}/wildfly-openssl-${WILDFLY_OPENSSL_VERSION}.jar" && \
    wget --quiet -P "${SPARK_HOME}/jars/" "${MAVEN_REPO_URL}/com/amazonaws/aws-java-sdk-glue/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-glue-${AWS_JAVA_SDK_VERSION}.jar" && \
    wget --quiet -P "${SPARK_HOME}/jars/" "${MAVEN_REPO_URL}/com/amazonaws/aws-java-sdk-core/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-core-${AWS_JAVA_SDK_VERSION}.jar" && \
    wget --quiet -P "${SPARK_HOME}/jars/" "${MAVEN_REPO_URL}/com/amazonaws/aws-java-sdk-sts/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-sts-${AWS_JAVA_SDK_VERSION}.jar"
