// Security-rules tests for firestore.rules, run against the Firestore emulator:
//   cd firebase/test && npm install && npm test
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  deleteDoc,
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';

const UID = 'alice';
let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-busiserve',
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});
after(() => env.cleanup());
beforeEach(() => env.clearFirestore());

const verified = () => env.authenticatedContext(UID, { email: 'alice@example.com', email_verified: true }).firestore();
const unverified = () => env.authenticatedContext(UID, { email: 'alice@example.com', email_verified: false }).firestore();

let seq = 0;
const uuid = () => {
  const n = (++seq).toString(16).padStart(12, '0');
  return `0000000${seq % 10}-0000-4000-8000-${n}`;
};

const enquiry = () => ({
  name: 'Alice Doe',
  email: 'alice@example.com',
  subject: 'general',
  message: 'We need a new website for our shop.',
  source: 'mobile_app',
  customerId: UID,
  status: 'received',
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
});

/** Seeds users/{UID}/limits/{kind} as if earlier writes had happened. */
const seedLimit = (kind, { lastAgoMs, windowAgoMs, count }) =>
  env.withSecurityRulesDisabled((ctx) =>
    setDoc(doc(ctx.firestore(), `users/${UID}/limits/${kind}`), {
      last: Timestamp.fromMillis(Date.now() - lastAgoMs),
      windowStart: Timestamp.fromMillis(Date.now() - windowAgoMs),
      count,
      lastId: 'seed',
    }),
  );

/** Mirrors RateLimits.spend in the app. */
async function spend(db, batch, kind, docId) {
  const ref = doc(db, `users/${UID}/limits/${kind}`);
  const snap = await getDoc(ref);
  const data = snap.exists() ? snap.data() : null;
  const inWindow = data && data.windowStart.toMillis() + 24 * 3600e3 > Date.now();
  batch.set(
    ref,
    inWindow
      ? { last: serverTimestamp(), windowStart: data.windowStart, count: data.count + 1, lastId: docId }
      : { last: serverTimestamp(), windowStart: serverTimestamp(), count: 1, lastId: docId },
  );
}

async function sendEnquiry(db, id = uuid()) {
  const batch = writeBatch(db);
  await spend(db, batch, 'enquiry', id);
  batch.set(doc(db, `enquiries/${id}`), enquiry());
  return batch.commit();
}

describe('enquiries', () => {
  test('verified user with a spent limit can create', async () => {
    await assertSucceeds(sendEnquiry(verified()));
  });

  test('unverified email is rejected', async () => {
    await assertFails(sendEnquiry(unverified()));
  });

  test('create without spending the limit is rejected', async () => {
    await assertFails(setDoc(doc(verified(), `enquiries/${uuid()}`), enquiry()));
  });

  test('second enquiry inside the 2-minute cooldown is rejected', async () => {
    const db = verified();
    await assertSucceeds(sendEnquiry(db));
    await assertFails(sendEnquiry(db));
  });

  test('allowed again after the cooldown', async () => {
    await seedLimit('enquiry', { lastAgoMs: 3 * 60e3, windowAgoMs: 3600e3, count: 4 });
    await assertSucceeds(sendEnquiry(verified()));
  });

  test('sixth enquiry in 24 hours is rejected', async () => {
    await seedLimit('enquiry', { lastAgoMs: 3 * 60e3, windowAgoMs: 3600e3, count: 5 });
    await assertFails(sendEnquiry(verified()));
  });

  test('a new 24-hour window resets the count', async () => {
    await seedLimit('enquiry', { lastAgoMs: 25 * 3600e3, windowAgoMs: 25 * 3600e3, count: 5 });
    await assertSucceeds(sendEnquiry(verified()));
  });

  test('one limit update cannot pay for two enquiries in one batch', async () => {
    const db = verified();
    const a = uuid();
    const batch = writeBatch(db);
    await spend(db, batch, 'enquiry', a);
    batch.set(doc(db, `enquiries/${a}`), enquiry());
    batch.set(doc(db, `enquiries/${uuid()}`), enquiry());
    await assertFails(batch.commit());
  });
});

describe('limit documents', () => {
  test('cannot be deleted to reset the counter', async () => {
    const db = verified();
    await assertSucceeds(sendEnquiry(db));
    await assertFails(deleteDoc(doc(db, `users/${UID}/limits/enquiry`)));
  });

  test('cannot lower the count', async () => {
    await seedLimit('enquiry', { lastAgoMs: 3 * 60e3, windowAgoMs: 3600e3, count: 5 });
    const db = verified();
    await assertFails(
      updateDoc(doc(db, `users/${UID}/limits/enquiry`), { last: serverTimestamp(), count: 1, lastId: 'x' }),
    );
  });

  test("cannot be written for another user", async () => {
    await assertFails(
      setDoc(doc(verified(), 'users/bob/limits/enquiry'), {
        last: serverTimestamp(),
        windowStart: serverTimestamp(),
        count: 1,
        lastId: 'x',
      }),
    );
  });
});

describe('support tickets', () => {
  async function createTicket(db, ticketId) {
    const messageId = `m-${ticketId}`;
    const batch = writeBatch(db);
    await spend(db, batch, 'ticket', ticketId);
    await spend(db, batch, 'message', messageId);
    batch.set(doc(db, `tickets/${ticketId}`), {
      customerId: UID,
      subject: 'Website is down',
      category: 'technical',
      status: 'open',
      lastMessage: 'Our site shows an error.',
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    batch.set(doc(db, `tickets/${ticketId}/messages/${messageId}`), {
      authorId: UID,
      authorRole: 'customer',
      authorName: 'Alice',
      text: 'Our site shows an error.',
      createdAt: serverTimestamp(),
    });
    return batch.commit();
  }

  async function reply(db, ticketId, messageId) {
    const batch = writeBatch(db);
    await spend(db, batch, 'message', messageId);
    batch.set(doc(db, `tickets/${ticketId}/messages/${messageId}`), {
      authorId: UID,
      authorRole: 'customer',
      authorName: 'Alice',
      text: 'Any update?',
      createdAt: serverTimestamp(),
    });
    batch.update(doc(db, `tickets/${ticketId}`), {
      lastMessage: 'Any update?',
      status: 'open',
      updatedAt: serverTimestamp(),
    });
    return batch.commit();
  }

  test('verified user can open a ticket with its first message', async () => {
    await assertSucceeds(createTicket(verified(), 't1'));
  });

  test('unverified user cannot open a ticket', async () => {
    await assertFails(createTicket(unverified(), 't1'));
  });

  test('relatedId must be a short string', async () => {
    const db = verified();
    const batch = writeBatch(db);
    await spend(db, batch, 'ticket', 't1');
    batch.set(doc(db, 'tickets/t1'), {
      customerId: UID,
      subject: 'Website is down',
      category: 'technical',
      status: 'open',
      relatedId: 'x'.repeat(500),
      lastMessage: 'Our site shows an error.',
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    await assertFails(batch.commit());
  });

  test('replies are throttled to one per 3 seconds', async () => {
    const db = verified();
    await assertSucceeds(createTicket(db, 't1'));
    await seedLimit('message', { lastAgoMs: 10e3, windowAgoMs: 60e3, count: 1 });
    await assertSucceeds(reply(db, 't1', 'm2'));
    await assertFails(reply(db, 't1', 'm3'));
  });
});
