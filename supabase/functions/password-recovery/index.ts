const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const jsonResponse = (status: number, body: Record<string, unknown>) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

const secret = (name: string) => {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`Missing server secret: ${name}`);
  return value;
};

const hex = (bytes: Uint8Array) =>
  Array.from(bytes, (byte) => byte.toString(16).padStart(2, "0")).join("");

async function digest(value: string) {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret("CODE_HASH_SECRET")),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  return hex(new Uint8Array(await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(value))));
}

function randomCode() {
  const limit = Math.floor(0x100000000 / 1_000_000) * 1_000_000;
  const value = new Uint32Array(1);
  do {
    crypto.getRandomValues(value);
  } while (value[0] >= limit);
  return value[0] % 1_000_000;
}

function randomToken() {
  const bytes = new Uint8Array(32);
  crypto.getRandomValues(bytes);
  return hex(bytes);
}

async function rpc(name: string, args: Record<string, string>) {
  const response = await fetch(`${secret("SUPABASE_URL")}/rest/v1/rpc/${name}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "apikey": secret("SUPABASE_SERVICE_ROLE_KEY"),
      "Authorization": `Bearer ${secret("SUPABASE_SERVICE_ROLE_KEY")}`,
    },
    body: JSON.stringify(args),
  });
  if (!response.ok) {
    console.error(`RPC ${name} failed:`, response.status, await response.text());
    throw new Error("O serviço de recuperação está indisponível.");
  }
  return response.json();
}

async function updateAuthPassword(email: string, password: string) {
  const baseUrl = secret("SUPABASE_URL");
  const serviceRoleKey = secret("SUPABASE_SERVICE_ROLE_KEY");
  const profileUrl = new URL(`${baseUrl}/rest/v1/user_profiles`);
  profileUrl.searchParams.set("select", "id");
  profileUrl.searchParams.set("email", `eq.${email}`);
  profileUrl.searchParams.set("limit", "1");
  const profileResponse = await fetch(profileUrl, {
    headers: {
      "apikey": serviceRoleKey,
      "Authorization": `Bearer ${serviceRoleKey}`,
    },
  });
  if (!profileResponse.ok) {
    console.error("Profile lookup failed:", profileResponse.status, await profileResponse.text());
    throw new Error("Não foi possível localizar a conta para redefinir a senha.");
  }
  const profiles = await profileResponse.json();
  const userId = Array.isArray(profiles) ? profiles[0]?.id : null;
  if (typeof userId !== "string") {
    throw new Error("Não foi possível concluir a redefinição desta conta.");
  }

  const updateResponse = await fetch(`${baseUrl}/auth/v1/admin/users/${userId}`, {
    method: "PUT",
    headers: {
      "apikey": serviceRoleKey,
      "Authorization": `Bearer ${serviceRoleKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ password }),
  });
  if (!updateResponse.ok) {
    console.error("Password update failed:", updateResponse.status, await updateResponse.text());
    throw new Error("Não foi possível atualizar a senha. Solicite um novo código.");
  }
}

async function sendEmail(email: string, code: string) {
  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${secret("RESEND_API_KEY")}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: secret("RESEND_FROM_EMAIL"),
      to: [email],
      subject: "Seu código de recuperação BusFlow",
      text: `Seu código de recuperação é ${code}. Ele expira em 15 minutos. Se você não solicitou esta alteração, ignore este e-mail.`,
      html: `<p>Seu código de recuperação BusFlow é:</p><p style="font-size:28px;font-weight:bold;letter-spacing:8px">${code}</p><p>Ele expira em 15 minutos. Se você não solicitou esta alteração, ignore este e-mail.</p>`,
    }),
  });
  if (!response.ok) {
    console.error("Email provider failed:", response.status, await response.text());
    throw new Error("Não foi possível enviar o e-mail de recuperação.");
  }
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return jsonResponse(405, { error: "Método não permitido." });
  }
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (
    !anonKey ||
    request.headers.get("apikey") !== anonKey ||
    request.headers.get("Authorization") !== `Bearer ${anonKey}`
  ) {
    return jsonResponse(401, { error: "Chave pública do aplicativo ausente ou inválida." });
  }

  try {
    const body = await request.json();
    const action = body?.action;

    if (action === "request_code") {
      const email = typeof body.email === "string" ? body.email.trim().toLowerCase() : "";
      if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
        return jsonResponse(400, { error: "Informe um e-mail válido." });
      }

      let code = "";
      let issued = false;
      const sourceAddress =
        request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ??
        request.headers.get("cf-connecting-ip") ??
        request.headers.get("x-real-ip") ??
        `email:${email}`;
      for (let attempt = 0; attempt < 10; attempt++) {
        code = String(randomCode()).padStart(6, "0");
        const status = await rpc("issue_password_reset_code", {
          p_email: email,
          p_code_hash: await digest(code),
          p_ip_hash: await digest(`ip:${sourceAddress}`),
        });
        if (status === "issued") {
          issued = true;
          break;
        }
        if (status === "email_rate_limited") {
          return jsonResponse(429, { error: "Aguarde 60 segundos antes de solicitar outro código para este e-mail." });
        }
        if (status === "ip_rate_limited") {
          return jsonResponse(429, { error: "Limite de solicitações atingido. Tente novamente em 15 minutos." });
        }
        if (status !== "collision") {
          throw new Error("Não foi possível registrar a solicitação de recuperação.");
        }
      }
      if (!issued) {
        return jsonResponse(503, { error: "Não foi possível gerar um código exclusivo. Tente novamente." });
      }

      try {
        await sendEmail(email, code);
      } catch (error) {
        await rpc("invalidate_password_reset_code", { p_email: email });
        throw error;
      }
      return jsonResponse(200, { ok: true });
    }

    if (action === "verify_code") {
      const email = typeof body.email === "string" ? body.email.trim().toLowerCase() : "";
      const code = typeof body.code === "string" ? body.code : "";
      if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email) || !/^\d{6}$/.test(code)) {
        return jsonResponse(400, { error: "Código inválido ou expirado." });
      }
      const token = randomToken();
      const status = await rpc("verify_password_reset_code", {
        p_email: email,
        p_code_hash: await digest(code),
        p_reset_token_hash: await digest(token),
      });
      if (status !== "verified") {
        return jsonResponse(400, { error: "Código inválido, expirado ou bloqueado." });
      }
      return jsonResponse(200, { ok: true, resetToken: token });
    }

    if (action === "complete_reset") {
      const token = typeof body.resetToken === "string" ? body.resetToken : "";
      const password = typeof body.password === "string" ? body.password : "";
      if (!/^[a-f0-9]{64}$/.test(token) || password.length < 6) {
        return jsonResponse(400, { error: "Sessão de redefinição inválida ou expirada." });
      }
      const email = await rpc("consume_password_reset_token_email", {
        p_reset_token_hash: await digest(token),
      });
      if (typeof email !== "string" || !email) {
        return jsonResponse(400, { error: "Sessão de redefinição inválida ou expirada." });
      }
      await updateAuthPassword(email, password);
      return jsonResponse(200, { ok: true });
    }

    return jsonResponse(400, { error: "Ação de recuperação inválida." });
  } catch (error) {
    console.error("Password recovery failed:", error);
    return jsonResponse(500, {
      error: error instanceof Error ? error.message : "Falha inesperada na recuperação.",
    });
  }
});
