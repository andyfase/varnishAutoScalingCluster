#
# Varnish "Cluster" Code.
# We configure varnish into "frontend" and "backend" virtual states for a individual request.
# The inital request will come into one of many Varnish nodes (from a ELB or similiar). This request is considered "frontend"
# The "frontend" requested is routed through to the appropiate varnish host or cache shard based on a keyed hash algorithm.
# To Do this we utilize the "hash" director. We also ensure no content is ever stored within frontend by setting the response as "uncacheable"
# When the request is routed to the second varnish instance (which could be itself) it is considered "backend". The request can from then on be treated normally.

# This frontend / backend differentiation allows for a horizontally scaling, highly available in-memory sharded cache.

# Three headers control the code behaviour. These are set inside the VCL and if needed removed before the HTTP response is delivered to the client.
# X-Varnish-Cluster-Frontend - This request header is introduced in frontend code. Its presence is initially checked for in vcl_recv to determine frontend/backend selection
# X-Varnish-Cluster-Backend - This response header is introduced on the backend vcl_deliver function so that its possible in later vcl functions the same frontend/backend selection
# X-Varnish-Cluster-Hash - This request header is set by both frontend and backend code. It is used to differentiate the cache in Varnish for storing the actual cache vs the instruction not to cache.

vcl 4.0;

import directors;

include "backend_auto.vcl";
include "vcl_frontend.vcl";
include "vcl_backend.vcl";

sub vcl_init {
  call backend_init;
}

sub vcl_recv {
    # Determination of frontend vs backend is done on presence of HTTP request header X-Varnish-Cluster-Frontend
    if (! req.http.X-Varnish-Cluster-Frontend) {
      call recv_frontend;
    } else {
      call recv_backend;
    }
}

sub vcl_hash {
  # Add value of X-Varnish-Cluster-Hash to the hashing input for cache storage.
  # This allows Varnish to store the actual final backend response and the instruction not to cache on the frontend seperatly (in the situation with the same varnish instance is both frontend and backend)
  hash_data(req.http.X-Varnish-Cluster-Hash);

  # Dont return as we we want the default hash vcl_hash code to continue (which adds URL and client IP I believe)
}

sub vcl_backend_response {
  # Determination of frontend vs backend is done on presence of HTTP response header X-Varnish-Cluster-Backend
    if (! beresp.http.X-Varnish-Cluster-Backend) {
      call backend_response_backend;
    } else {
      call backend_response_frontend;
    }
}

sub vcl_deliver {
    # Determination of frontend vs backend is done on presence of HTTP response header X-Varnish-Cluster-Backend
    if (! resp.http.X-Varnish-Cluster-Backend) {
      call deliver_backend;
    } else {
      call deliver_frontend;
    }
}
