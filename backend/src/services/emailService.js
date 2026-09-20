// Sends email via Resend if RESEND_API_KEY is set.
// Otherwise logs the email to the backend terminal so the flow can
// still be tested without a real email account.

async function sendEmail({ to, subject, html, text }) {
  const apiKey = process.env.RESEND_API_KEY;
  const from = process.env.FROM_EMAIL || 'CareHome Connect <onboarding@resend.dev>';

  if (!apiKey || apiKey.trim().length === 0) {
    console.log('----- EMAIL (dev mode, not sent) -----');
    console.log('To     :', to);
    console.log('From   :', from);
    console.log('Subject:', subject);
    if (text) console.log('Body   :\n' + text);
    console.log('--------------------------------------');
    return { skipped: true };
  }

  const body = {
    from,
    to,
    subject,
    html: html || undefined,
    text: text || undefined,
  };

  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`Resend error: ${response.status} ${text}`);
  }
  return response.json();
}

// Builds the invitation email body.
function buildInvitationEmail({ firstName, acceptUrl }) {
  const subject = 'You are invited to CareHome Connect';
  const text =
    `Hello ${firstName},\n\n` +
    `You have been invited to CareHome Connect, our care home management system.\n\n` +
    `Click the link below to set your password and activate your account.\n\n` +
    `${acceptUrl}\n\n` +
    `If you did not expect this invitation, you can ignore this email.\n`;

  const html = `
    <div style="font-family:Arial,sans-serif;max-width:520px;margin:auto;">
      <h2 style="color:#0F5B5B;">CareHome Connect</h2>
      <p>Hello ${firstName},</p>
      <p>You have been invited to CareHome Connect, our care home management system.</p>
      <p>Click the button below to set your password and activate your account.</p>
      <p style="text-align:center;margin:24px 0;">
        <a href="${acceptUrl}"
           style="background:#0F5B5B;color:#fff;padding:12px 22px;text-decoration:none;border-radius:8px;">
          Set my password
        </a>
      </p>
      <p style="font-size:12px;color:#666;">
        If the button does not work, copy this link into your browser:<br>
        <span style="word-break:break-all;">${acceptUrl}</span>
      </p>
      <p style="font-size:12px;color:#999;">
        If you did not expect this invitation, you can ignore this email.
      </p>
    </div>
  `;

  return { subject, text, html };
}

module.exports = { sendEmail, buildInvitationEmail };