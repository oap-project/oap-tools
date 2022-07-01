# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM oap-ubuntu:1.4.0

USER root

RUN wget https://github.com/oap-project/oap-project.github.io/raw/master/resources/analytics//tpcds-kit.tar.gz  && \
    mkdir -p /opt/home/tools && \
    tar -zxvf tpcds-kit.tar.gz -C /opt/home/tools && \
    rm tpcds-kit.tar.gz

ADD https://github.com/oap-project/oap-project.github.io/raw/master/resources/analytics/sparkbench-assembly-8.0-SNAPSHOT-dist.jar  /opt/home/tools/sparkbench-assembly-8.0-SNAPSHOT-dist.jar 

ADD https://github.com/oap-project/oap-project.github.io/raw/master/resources/analytics//spark-sql-perf_2.12-0.5.1-SNAPSHOT.jar  /opt/home/tools/spark-sql-perf_2.12-0.5.1-SNAPSHOT.jar

RUN chmod +r /opt/home/tools/sparkbench-assembly-8.0-SNAPSHOT-dist.jar
RUN chmod +r /opt/home/tools/spark-sql-perf_2.12-0.5.1-SNAPSHOT.jar

# Specify the User that the actual main process will run as
ARG spark_uid=185
USER ${spark_uid}

