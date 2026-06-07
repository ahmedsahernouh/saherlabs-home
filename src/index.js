const SECURITY_HEADERS = {
  "Strict-Transport-Security": "max-age=31536000; includeSubDomains; preload",
  "Content-Security-Policy":
    "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.bokeh.org https://cdnjs.cloudflare.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com data:; img-src 'self' data: blob: https:; connect-src 'self' https://api.saherlabs.dev; worker-src 'self' blob:; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'; upgrade-insecure-requests",
  "X-Content-Type-Options": "nosniff",
  "X-Frame-Options": "DENY",
  "X-XSS-Protection": "1; mode=block",
  "Referrer-Policy": "strict-origin-when-cross-origin",
  "Permissions-Policy": "camera=(), microphone=(), geolocation=(), payment=(), usb=()",
};

const PATH_REDIRECTS = new Map([
  ["/about.html", "/about"],
  ["/fieldviewer-intro.html", "/fieldviewer-intro"],
  ["/fieldviewer-ai-lab.html", "/fieldviewer-ai-lab"],
  ["/projects.html", "/projects"],
  ["/resume.html", "/resume"],
  ["/contact.html", "/contact"],
]);

function addSecurityHeaders(headers) {
  for (const [name, value] of Object.entries(SECURITY_HEADERS)) {
    headers.set(name, value);
  }
  return headers;
}

function secureResponse(response) {
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: addSecurityHeaders(new Headers(response.headers)),
  });
}

function redirect(location, status = 301) {
  return new Response(null, {
    status,
    headers: addSecurityHeaders(new Headers({ Location: location })),
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.hostname === "www.saherlabs.dev") {
      url.hostname = "saherlabs.dev";
      url.protocol = "https:";
      return redirect(url.toString(), 301);
    }

    if (url.protocol === "http:") {
      url.protocol = "https:";
      return redirect(url.toString(), 301);
    }

    if (url.pathname === "/fv") {
      return redirect("https://fieldviewer.saherlabs.dev", 302);
    }

    const cleanPath = PATH_REDIRECTS.get(url.pathname);
    if (cleanPath) {
      url.pathname = cleanPath;
      return redirect(url.toString(), 301);
    }

    return secureResponse(await env.ASSETS.fetch(request));
  },
};
