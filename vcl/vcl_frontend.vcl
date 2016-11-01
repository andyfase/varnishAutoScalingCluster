sub recv_frontend {
  # set backend as varnish hash director
  set req.backend_hint = varnish_backend.backend(req.url);

  # set header X-Varnish-Cluster-Frontend (value doesnt really matter)
  set req.http.X-Varnish-Cluster-Frontend = req.xid;

  # set X-Varnish-Cluster-Hash to differentiate hash key for cache
  set req.http.X-Varnish-Cluster-Hash = "frontend";

  ## dont return. We want the default hit-for-pass logic to kick in to stop any request coalescing
}

sub backend_response_frontend {
  set beresp.http.X-FE = bereq.xid;

  ### Never cache on frontend
  set beresp.uncacheable = true;
  set beresp.ttl = 60m;

  return (deliver);
}

sub deliver_frontend {
  # remove un-needed headers before we send out to client
  unset resp.http.X-Varnish-Cluster-Backend;
  unset resp.http.X-Varnish;
  unset resp.http.Server;
  unset resp.http.Via;

  # rename Age header to X-Cache
  set resp.http.X-Cache = resp.http.Age;
  unset resp.http.Age;

  # add frontend varnish server IP as response header just for demonstration purposes!!
  set resp.http.X-Varnish-Cluster-Frontend-Host = server.hostname;

  return(deliver);
}
