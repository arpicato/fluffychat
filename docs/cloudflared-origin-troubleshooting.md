# Cloudflared Origin Troubleshooting

On `arpin-hp.local`, we reproduced intermittent Cloudflare `502` responses when the Windows `cloudflared` service forwarded to a Docker-published nginx port using `localhost:<port>` as the origin URL.

Symptoms:

- Browser received a Cloudflare-generated `502` page after about 30 seconds.
- `cloudflared` debug logs showed the request and `cf-ray`.
- `messie-gateway` nginx did not log the same request, which meant nginx never handled it.

Working fix:

- Use `127.0.0.1:<port>` instead of `localhost:<port>` in the Windows `cloudflared` service origin URL.

Observed result:

- After switching the origin from `localhost:9090` to `127.0.0.1:9090`, the intermittent 502s stopped.

Notes:

- This finding applies to the Windows-service-to-Docker-published-port path on `arpin-hp.local`.
- Temporary high-volume nginx and `cloudflared` debug logging used during diagnosis was removed after the fix was confirmed.
