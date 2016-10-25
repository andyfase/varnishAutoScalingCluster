#
# Backend VCL file - this should be auto-generated by consul
#

backend http_backend1 {
    .host = "127.0.0.1";
    .port = "10000";
}

backend http_backend2 {
    .host = "127.0.0.1";
    .port = "10000";
}

backend varnish_backend1 {
  .host = "127.0.0.1";
  .port = "8080";
}

backend varnish_backend2 {
  .host = "127.0.0.1";
  .port = "8081";
}

sub backend_init {
  ## setup varnish backend hash director
  new varnish_backend = directors.hash();
  varnish_backend.add_backend(varnish_backend1, 1.0);
  varnish_backend.add_backend(varnish_backend2, 1.0);

  ## setup actual backend director, using round-robin
  new httpd_backend = directors.round_robin();
  httpd_backend.add_backend(http_backend1);
  httpd_backend.add_backend(http_backend2);
}
