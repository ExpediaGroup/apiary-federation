data "template_file" "hive_site_xml" {
  template = <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
     <name>apiary.path.replacement.enabled</name>
     <value>true</value>
  </property>
%{for alluxio_endpoint in var.alluxio_endpoints}
%{for s3_bucket in split(",", alluxio_endpoint.s3_buckets)}
   <property>
       <name>apiary.path.replacement.regex.alluxio-${s3_bucket}</name>
       <value>^(s3[an]?://)${s3_bucket}/.*$</value>
   </property>
   <property>
       <name>apiary.path.replacement.value.alluxio-${s3_bucket}</name>
       <value>${alluxio_endpoint.root_url}</value>
   </property>
   <property>
       <name>apiary.path.replacement.capturegroups.alluxio-${s3_bucket}</name>
       <value>1</value>
   </property>
%{endfor}
%{endfor}
</configuration>
EOF
}
