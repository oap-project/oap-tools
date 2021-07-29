#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

OAP_ENV=/opt/home/conda/envs/oap-1.2.0

sh ../spark/spark-shell-client.sh --conf spark.executor.instances=1 \
--conf spark.driver.extraClassPath=$OAP_ENV/oap_jars/spark-columnar-core-1.2.0-jar-with-dependencies.jar:$OAP_ENV/oap_jars/spark-arrow-datasource-standard-1.2.0-jar-with-dependencies.jar \
  --conf spark.driver.maxResultSize=15g \
  --conf spark.executorEnv.LD_LIBRARY_PATH=$OAP_ENV/lib \
  --conf spark.executorEnv.LIBARROW_DIR=$OAP_ENV \
  --conf spark.sql.extensions=com.intel.oap.ColumnarPlugin \
  --conf spark.executor.extraClassPath=$OAP_ENV/oap_jars/spark-columnar-core-1.2.0-jar-with-dependencies.jar:$OAP_ENV/oap_jars/spark-arrow-datasource-standard-1.2.0-jar-with-dependencies.jar \
  --conf spark.sql.columnar.sort=true \
  --conf spark.executor.extraLibraryPath=$OAP_ENV/lib \
  --conf spark.sql.execution.arrow.maxRecordsPerBatch=20480 \
  --conf spark.sql.parquet.columnarReaderBatchSize=20480 \
  --conf spark.shuffle.manager=org.apache.spark.shuffle.sort.ColumnarShuffleManager \
  --conf spark.driver.extraLibraryPath=$OAP_ENV/lib \
  --conf spark.sql.columnar.codegen.hashAggregate=true \
  --conf spark.executorEnv.CC=$OAP_ENV/bin/gcc \
  --conf spark.memory.offHeap.size=30g

