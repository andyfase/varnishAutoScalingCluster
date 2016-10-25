sub recv_backend {
  # set backend as httpd round-robin director
  set req.backend_hint = httpd_backend.backend();

  # re-set X-Varnish-Cluster-Hash to differentiate hash key for cache
  set req.http.X-Varnish-Cluster-Hash = "backend";

  return (hash);
}

sub backend_response_backend {
  set beresp.http.X-BE = bereq.xid;

  return(deliver);
}

sub deliver_backend {
  # set responde header X-Varnish-Cluster-Backend (value doesnt really matter)
  set resp.http.X-Varnish-Cluster-Backend = req.xid;

  return(deliver);
}
