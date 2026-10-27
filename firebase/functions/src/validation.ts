/**
 * Server-side validation. Mirrors lib/core/utils/validators.dart and
 * AppLimits on the client, but this is the version that counts.
 */
export const LIMITS = {
  nameMin: 2,
  nameMax: 80,
  messageMin: 10,
  messageMax: 3000,
  companyMax: 120,
} as const;

export const SUBJECTS = [
  "general", "web-development", "wordpress-development", "shopify-development",
  "app-development", "game-design", "ui-ux-design", "cms-development",
  "crm-development", "erp-development", "api-development",
  "ai-agent-development", "automation-n8n", "partnership",
] as const;

const UUID_V4 = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
const NAME = /^[\p{L}][\p{L} .'-]*$/u;
const PHONE_CHARS = /^\+?[0-9 \-()]+$/;

export interface EnquiryInput {
  idempotencyKey: string;
  name: string;
  email: string;
  subject: string;
  message: string;
  phone?: string;
  company?: string;
  source: string;
}

export type ValidationResult =
  | { ok: true; value: EnquiryInput }
  | { ok: false; fields: Record<string, string> };

const asString = (v: unknown): string => (typeof v === "string" ? v.trim() : "");

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function validateEnquiry(raw: any): ValidationResult {
  const fields: Record<string, string> = {};
  const data = typeof raw === "object" && raw !== null ? raw : {};

  const idempotencyKey = asString(data.idempotencyKey).toLowerCase();
  if (!UUID_V4.test(idempotencyKey)) fields.idempotencyKey = "Invalid request id.";

  const name = asString(data.name);
  if (name.length < LIMITS.nameMin || name.length > LIMITS.nameMax || !NAME.test(name)) {
    fields.name = "Enter your full name.";
  }

  const email = asString(data.email).toLowerCase();
  if (email.length > 254 || !EMAIL.test(email)) fields.email = "Enter a valid email address.";

  const subject = asString(data.subject);
  if (!(SUBJECTS as readonly string[]).includes(subject)) fields.subject = "Choose a subject.";

  const message = asString(data.message);
  if (message.length < LIMITS.messageMin) fields.message = `Message must be at least ${LIMITS.messageMin} characters.`;
  if (message.length > LIMITS.messageMax) fields.message = `Message must be ${LIMITS.messageMax} characters or fewer.`;

  const phone = asString(data.phone);
  if (phone) {
    const digits = phone.replace(/\D/g, "");
    if (!PHONE_CHARS.test(phone) || digits.length < 8 || digits.length > 15) {
      fields.phone = "Enter a valid phone number.";
    }
  }

  const company = asString(data.company);
  if (company.length > LIMITS.companyMax) fields.company = "Company name is too long.";

  const source = asString(data.source) === "mobile_app" ? "mobile_app" : "unknown";

  if (Object.keys(fields).length > 0) return { ok: false, fields };
  return {
    ok: true,
    value: {
      idempotencyKey, name, email, subject, message, source,
      ...(phone ? { phone } : {}),
      ...(company ? { company } : {}),
    },
  };
}
