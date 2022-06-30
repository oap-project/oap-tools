![logo](./image/logo.jpg)

Optimized Analytics Package (OAP) is an open source project to optimize Apache Spark on SQL engine, MLlib and so on, driven by Intel and the community.

# <font size="6"><b>Why use OAP?</b></font>

Apache Spark is powerful and well optimized on many aspects, but it still faces some challenges to achieve a higher-level performance.

- The JVM and row-based computing engine prevents Spark to be fully optimized for Intel hardware, for example AVX/AVX512, GPU.

- The current implementation of key aspects, such as memory management & shuffle, doesn't consider the latest technology advancements,  like PMEM.

- The batch processing engine cannot satisfy the need of queries with high performance requirement.

OAP Project aims to optimize Spark on these aspects above. It had 6 components, including **Gazelle Plugin**, **OAP MLlib**, **SQL DS Cache**, **PMem Spill**, **PMem Common**, and **PMem Shuffle** in previous releases.

Since 1.3, OAP consists of 2 components: **Gazelle Plugin** and **OAP MLlib**.

![Overview](./image/OAP-Components.png)

# <font size="6"><b>How to use OAP?</b></font>

## Guide

Please refer to OAP project installation and developer guide below for instructions.

* [OAP Installation Guide](./OAP-Installation-Guide.md)
* [OAP Developer Guide](./OAP-Developer-Guide.md)

## Components

You can get more detailed information from each component web page of OAP Project below.

* [Gazelle Plugin](https://oap-project.github.io/gazelle_plugin/)
* [OAP MLlib](https://oap-project.github.io/oap-mllib/)
