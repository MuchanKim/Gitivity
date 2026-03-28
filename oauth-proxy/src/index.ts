export interface Env {
  GITHUB_CLIENT_ID: string;
  GITHUB_CLIENT_SECRET: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    if (request.method !== "POST") {
      return new Response("Method Not Allowed", { status: 405 });
    }

    const url = new URL(request.url);
    if (url.pathname !== "/token") {
      return new Response("Not Found", { status: 404 });
    }

    const body = await request.json<{ code?: string }>();
    if (!body.code) {
      return Response.json({ error: "missing code" }, { status: 400 });
    }

    const response = await fetch(
      "https://github.com/login/oauth/access_token",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify({
          client_id: env.GITHUB_CLIENT_ID,
          client_secret: env.GITHUB_CLIENT_SECRET,
          code: body.code,
        }),
      }
    );

    const data = await response.json();

    return Response.json(data, {
      status: response.ok ? 200 : 400,
    });
  },
};
