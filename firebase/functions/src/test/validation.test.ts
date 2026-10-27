import { strict as assert } from "node:assert";
import { test } from "node:test";

import { validateEnquiry } from "../validation";

const valid = {
  idempotencyKey: "3b241101-e2bb-4255-8caf-4136c566a962",
  name: "Asha Verma",
  email: "Asha@Example.com",
  subject: "app-development",
  message: "We need an Android and iOS app for our clinic.",
  source: "mobile_app",
};

test("accepts a valid enquiry and normalises email", () => {
  const r = validateEnquiry(valid);
  assert.equal(r.ok, true);
  if (r.ok) assert.equal(r.value.email, "asha@example.com");
});

test("rejects unknown subject and short message", () => {
  const r = validateEnquiry({ ...valid, subject: "crypto", message: "hi" });
  assert.equal(r.ok, false);
  if (!r.ok) {
    assert.ok(r.fields.subject);
    assert.ok(r.fields.message);
  }
});

test("rejects non-v4 idempotency keys", () => {
  const r = validateEnquiry({ ...valid, idempotencyKey: "not-a-uuid" });
  assert.equal(r.ok, false);
});

test("ignores client-supplied customerId", () => {
  const r = validateEnquiry({ ...valid, customerId: "someone-else" });
  assert.equal(r.ok, true);
  if (r.ok) assert.equal((r.value as unknown as Record<string, unknown>).customerId, undefined);
});
