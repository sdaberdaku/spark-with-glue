FROM spark:3.5.7-scala2.12-java17-python3-ubuntu

ARG SPARK_GLUE_CLIENT_URL="https://github.com/sdaberdaku/aws-glue-data-catalog-spark-client"
ARG SPARK_GLUE_CLIENT_TAG=v3.5.x
ARG HIVE2_VERSION=2.3.9
ARG AWS_JAVA_SDK_VERSION=1.12.262
ARG PY4J_VERSION=0.10.9.7

ENV SPARK_HOME=/opt/spark
ENV PYTHONPATH="${SPARK_HOME}/python/lib/py4j-${PY4J_VERSION}-src.zip:${SPARK_HOME}/python/lib/pyspark.zip"

# wget must overwrite the existing hive-common-*.jar and hive-exec-*-core.jar files with the patched ones.
RUN wget --quiet -O "${SPARK_HOME}/jars/aws-glue-datacatalog-spark-client.jar" "${SPARK_GLUE_CLIENT_URL}/releases/download/${SPARK_GLUE_CLIENT_TAG}/aws-glue-datacatalog-spark-client.jar" && \
    wget --quiet -O "${SPARK_HOME}/jars/hive-common-${HIVE2_VERSION}.jar" "${SPARK_GLUE_CLIENT_URL}/releases/download/${SPARK_GLUE_CLIENT_TAG}/hive-common-${HIVE2_VERSION}.jar" && \
    wget --quiet -O "${SPARK_HOME}/jars/hive-exec-${HIVE2_VERSION}-core.jar" "${SPARK_GLUE_CLIENT_URL}/releases/download/${SPARK_GLUE_CLIENT_TAG}/hive-exec-${HIVE2_VERSION}-core.jar" && \
    wget --quiet -O "${SPARK_HOME}/jars/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar" "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar"

