#
# Backend VCL file - this should be auto-generated by consul
#


backend httpd_ip_127_0_0_1 {
    .host = "127.0.0.1";
    .port = "81";
}

backend varnish_ip_127_0_0_1 {
  .host = "127.0.0.1";
  .port = "80";
}

sub backend_init {
  ## setup varnish backend hash director
  new varnish_backend = directors.hash();
  varnish_backend.add_backend(varnish_ip_127_0_0_1, 1.0);

  ## setup actual backend director, using round-robin
  new httpd_backend = directors.round_robin();
  httpd_backend.add_backend(httpd_ip_127_0_0_1);
}